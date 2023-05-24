#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
int nexttid = 0;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

//PAGEBREAK: 32
// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  // p->pid = nextpid++;

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");
  p->stacksz = 1;

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();
  struct proc *p;

  sz = curproc->sz;
  if(n > 0){
    // sz: oldsz, sz + n: newsz
    if (curproc->mlimit != 0 && sz + n > curproc->mlimit) // memory limitation
      return -1;
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  // pid가 동일한 스레드 간 heap 메모리 영역을 공유할 수 있게 함
  // 새로 생성되는 스레드에 대한 스택 영역이 힙 영역을 침범하지 않도록 함
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == curproc->pid)
      p->sz = curproc->sz;
  }
  release(&ptable.lock);
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }
  np->pid = nextpid++;

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->stacksz = curproc->stacksz;
  np->parent = curproc;
  *np->tf = *curproc->tf;
  np->isThread = 0;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  thread_clear(curproc); // exit without joining
  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  // clear all thread
  acquire(&ptable.lock);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      if(p->isThread) // wait thread in thread_join
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}

//PAGEBREAK: 42
// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      c->proc = p;
      switchuvm(p);
      p->state = RUNNING;

      swtch(&(c->scheduler), p->context);
      switchkvm();

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      c->proc = 0;
    }
    release(&ptable.lock);

  }
}

// Enter scheduler.  Must hold only ptable.lock : 스케줄러로 들어갑니다. ptable.lock만 걸려 있어야 함
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler); // 프로세스에서 스케줄러로
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE; //실행 중인 프로세스를 RUNNABLE 상태로 전환시킴
  sched(); // switch to scheduler
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0; // 프로세스를 exit (종료) 시키기 위해 return ! 정상종료: 0
    }
  }
  release(&ptable.lock);
  return -1;
}

//PAGEBREAK: 36
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}

int
setmemorylimit(int pid, int limit)
{
  struct proc *p;

  if(limit < 0)
    return -1;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      if(limit && p->sz > limit)
        return -1;
      else{
        p->mlimit = limit;
        return 0;
      }
    }
  }
  return -1; // pid not found
}

// thread control
int
thread_create(thread_t *thread, void *(*start_routine)(void *), void *arg)
{
    int i;
    uint sz, sp, ustack[2];
    struct proc *nt, *p;
    struct proc *curproc = myproc();

    // Allocate thread
    if((nt = allocproc()) == 0){
        return -1;
    }
    nt->pid = curproc->pid;
    nt->pgdir = curproc->pgdir; // share text, data, heap memory with main thread
    nt->sz = curproc->sz;
    nt->stacksz = curproc->stacksz;
    nt->parent = curproc->parent; // (?) thread의 부모 프로세스는 생성 프로세스의 부모 프로세스를 따라가기.. 어디서 생성되었는지는 pid를 보면 알 수 있으니까
    *nt->tf = *curproc->tf;

    nt->isThread = 1;
    nt->main = curproc;
    nt->retval = 0;
    nt->tid = nexttid++;
    
    nt->tf->eax = 0; // start_routine에서 알아서 처리 될 거니까 추가 안 해도 될듯.? 아 확신은 없다 근뎁
    
    for(i = 0; i < NOFILE; i++)
        if(curproc->ofile[i])
            nt->ofile[i] = filedup(curproc->ofile[i]); // filedup, idup는 단순히 ref (reference 인듯?) 개수를 1씩 증가시켜주는 거니까.. 이렇게 해도 될듯
    nt->cwd = idup(curproc->cwd);

    // allocate user stack
    sz = nt->sz;
    if((sz = allocuvm(nt->pgdir, sz, sz + (curproc->stacksz + 1)*PGSIZE)) == 0)
        return -1;
    clearpteu(nt->pgdir, (char*)(sz - (curproc->stacksz + 1)*PGSIZE));
    sp = sz;
    nt->sz = sz;
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
        if(p->pid == curproc->pid)
            p->sz = sz;
    }
    release(&ptable.lock);
    
    // Push argument strings, prepare rest of stack in ustack.
    ustack[1] = (uint)arg; // argument of start_routine
    ustack[0] = 0xffffffff; // fake return PC *어차피 exit로 종료되므로 fake 값 넣어둠

    sp -= 2 * 4;
    if(copyout(nt->pgdir, sp, ustack, 2*4) < 0)
        return -1;
    nt->tf->esp = sp;

    safestrcpy(nt->name, curproc->name, sizeof(curproc->name));

    nt->tf->eip = (uint)start_routine; // (?) allocproc에서 forkret 실행시키는거 따라함.. 잘 되는군

    acquire(&ptable.lock);
    nt->state = RUNNABLE;
    release(&ptable.lock);
    *thread = nt->tid;
    return 0;
}

// Equivalent to exit(void) for process
void thread_exit(void *retval)
{
  struct proc *curthread = myproc();
  struct proc *p;
  int fd;

  #ifdef DEBUG
  cprintf("in thread_exit\n");
  #endif
  if(curthread == initproc)
    panic("init exiting");
  
  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curthread->ofile[fd]){
      fileclose(curthread->ofile[fd]);
      curthread->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curthread->cwd);
  end_op();
  curthread->cwd = 0;

  curthread->retval = retval;

  acquire(&ptable.lock);

  // Parent might be sleeping in thread_join().
  wakeup1(curthread->main); // parent가 아니라 메인 스레드를 깨워야 함

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curthread){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curthread->state = ZOMBIE;
  #ifdef DEBUG
  cprintf("out thread_exit\n");
  #endif
  sched();
  panic("zombie exit");
}

// Equivalent to wait(void) for process
int thread_join(thread_t thread, void **retval)
{
  struct proc *p;
  int havekids;
  struct proc *curthread = myproc();
  
  acquire(&ptable.lock);
  #ifdef DEBUG
  cprintf("in join\n");
  #endif
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->main != curthread)
        continue;
      havekids = 1;
      if(p->tid == thread && p->state == ZOMBIE){
        // Found one.
        *retval = p->retval;
        kfree(p->kstack);
        p->kstack = 0;
        // freevm(p->pgdir);
        // stack 공간은 free 해 주어야 하는거 아닌가..?
        // 아 어차피 메인 스레드 프로세스가 종료될 때 해결되겠구나..!
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->mlimit = 0;
        p->isThread = 0;
        p->main = 0;
        p->retval = 0;
        p->tid = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return 0;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curthread->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curthread, &ptable.lock);  //DOC: wait-sleep
  }
}

void
thread_clear(struct proc *curproc)
{
  struct proc *p;
  int fd;

  // 스레드에서 exec가 호출된 경우
  // 스레드보다 process가 먼저 exit 되는 경우
  if(curproc->isThread) {
    curproc->isThread = 0;
    // make original main thread (process) to thread
    curproc->main->isThread = 1;
    curproc->main = 0;
  }
  // clear all threads
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == curproc->pid && p->isThread && p->state != UNUSED) {
      if(p == initproc)
        panic("init exiting");
      if(p->state != ZOMBIE) {
        // Close all open files.
        for(fd = 0; fd < NOFILE; fd++){
          if(p->ofile[fd]){
            fileclose(p->ofile[fd]);
            p->ofile[fd] = 0;
          }
        }
        begin_op();
        iput(p->cwd);
        end_op();
        p->cwd = 0;
        p->state = ZOMBIE;
      }
      if(p->state == ZOMBIE) {
        kfree(p->kstack);
        p->kstack = 0;
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->mlimit = 0;
        p->isThread = 0;
        p->main = 0;
        p->retval = 0;
        p->tid = 0;
        p->state = UNUSED;
      }
      // sz의 경우 exec 안에서 재설정 되므로 갱신 필요 없음
    }
  }
}

void
process_status(struct ps *s)
{
  struct proc *p;
  int i;

  acquire(&ptable.lock);
  for(p = ptable.proc, i = 0; p < &ptable.proc[NPROC]; p++){
    if((p->state == RUNNABLE || p->state == RUNNING || p->state == SLEEPING) && !p->isThread){
      s->info[i].sz = p->sz;
      s->info[i].pid = p->pid;
      s->info[i].stacksz = p->stacksz; // sum of stack size = main thread stack size + # of thread (cuz each thread has 1 user stack)
      s->info[i].mlimit = p->mlimit;
      safestrcpy(s->info[i].name, p->name, sizeof(s->info[i].name));
      i++;
    }
  }
  s->active = i;
  release(&ptable.lock);
}