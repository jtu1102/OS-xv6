#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "queue.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable; // 전역변수로 ptable 초기화.

struct {
  struct Queue l0;
  struct Queue l1;
  struct Queue l2;
} mlfq;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  cprintf("여기 들어오긴 하니...........????????\n");
  initQueue(&mlfq.l0);
  initQueue(&mlfq.l1);
  initQueue(&mlfq.l2);
  cprintf("init queue.......????????\n");
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
  return 0; // 프로세스 생성 공간이 부족할 경우 0을 리턴하고 fork 리턴값이 -1이 됨.

found:
  cprintf("allocproc?????\n");
  p->state = EMBRYO;
  p->pid = nextpid++;

  p->lev = 0;
  p->tq = 0;
  p->priority = 3;
  enqueue(&mlfq.l0, p); // push process to (L0) queue

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

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
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

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

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
  struct Queue tmp;
  c->proc = 0;
  
  for(;;){
    // Enable interrupts on this processor.
    sti();
    // Loop over process table looking for process to run.
    // MLFQ
    /* schedule process in L0 */
    // 각 프로세스 level 변경은 yield()에서 이루어짐
    initQueue(&tmp);

    acquire(&ptable.lock);
    while(!isEmpty(&mlfq.l0)){ // empty가 아니라 RUNNABLE한 프로세스의 존재 여부를 확인해야 함....
      p = dequeue(&mlfq.l0);
      if(p->state == RUNNABLE){ // RUNNABLE한 프로세스인 경우 switch
        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;

        cprintf("[L0] [pid: %d] lets go~\n", p->pid);
        swtch(&(c->scheduler), p->context);
        switchkvm();
        if(p->lev == 1) // tq을 다 쓴 프로세스는 l1로 넘겨줌 (이때, state에 대해서는 고려하지 않고, l1에서 처리되도록 함)
          enqueue(&mlfq.l1, p);
        else if(p->lev == 0 && p->state != UNUSED) // tq이 남아 있고 아직 종료되지 않은 프로세스의 경우 l0 큐에 남겨두기 위해 임시저장
          enqueue(&tmp, p);
        c->proc = 0;
      }
      else // RUNNABLE한 프로세스가 아닌 경우 switch 하지 않음.
        if(p->state != UNUSED)
          enqueue(&tmp, p); // 아직 RUNNABLE로 전환될 여지가 남아 있을 경우, l0큐에 남겨두기 위해 임시저장
    }
    while(!isEmpty(&tmp)) // 임시 저장해 두었던 프로세스 L0로 복원 (case: UNUSED 이외의 RUNNABLE로 전환될 여지가 남아 있거나 ZOMBIE 상태의 프로세스인 경우)
      enqueue(&mlfq.l0, dequeue(&tmp));
    
    /* schedule process in L1 */
    int l1_size = mlfq.l1.count;
    int is_l1_have_runnable = 0;
    while(l1_size--){ // 가장 앞에 있는 RUNNABLE한 프로세스 찾기
      p = dequeue(&mlfq.l1);
      if(p->state == RUNNABLE){
        is_l1_have_runnable = 1;
        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;

        cprintf("[L1] [pid: %d] lets go~\n", p->pid);
        swtch(&(c->scheduler), p->context);
        switchkvm();
        if(p->lev == 2) // tq을 다 쓴 프로세스는 dequeue 하고, l2로 넘겨줌
          enqueue(&mlfq.l2, p);
        else if(p->lev == 1 && p->state != UNUSED) // tq이 남아 있을 경우 l1 큐에 그대로 남겨 둠
          enqueue(&mlfq.l1, p);
        
        c->proc = 0;
        break;
      }
      else if(p->state != UNUSED)
        enqueue(&mlfq.l1, p); // RUNNABLE로 전환될 여지가 남아 있음, L1의 맨 뒤로 보냄
    }
    /* schedule process in L2 */
    // L1큐에 실행할 프로세스가 없는 경우
    // L2큐를 순회하며 실행할 프로세스 고르기
    // 종료된 프로세스를 정리 해 주지 않으면.. 최악의 경우 l2 큐가 넘칠 수도 있음
    int priority_min = 4; // max: 3 이므로 처음 초기화를 위해 4로 설정하고 시작함
    struct proc *now;
    if(!is_l1_have_runnable){
      p = NULL;
      while(!isEmpty(&mlfq.l2)){ // L2의 프로세스 중 우선순위가 높고 L2에 먼저 들어온 프로세스 찾기
        now = dequeue(&mlfq.l2);
        if(now->state == RUNNABLE && now->priority < priority_min){
          p = now;
          priority_min = p->priority;
        }
        enqueue(&tmp, now); // L2 순서 그대로 tmp에 옮겨놓기
      }
      if(p){ // RUNNABLE한 프로세스 중 가장 우선순위가 낮은 프로세스를 찾았다면!
        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;

        cprintf("[L2] [pid: %d, priority: %d] lets go~\n", p->pid, p->priority);
        swtch(&(c->scheduler), p->context);
        switchkvm();
        
        c->proc = 0;
      }
      while(!isEmpty(&tmp)){ // l2 순서 복원하여 다시 넣기, UNUSED된 프로세스는 정리
        now = dequeue(&tmp);
        if(now->state != UNUSED)
          enqueue(&mlfq.l2, now);
      }
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
  if(myproc()->lev != 2)
    myproc()->lev++;
  else if(myproc()->lev == 2){ // L2의 큐가 tq을 모두 소비한 경우
    if(myproc()->priority > 0)
      myproc()->priority--;
    myproc()->tq = 0;
  }
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
