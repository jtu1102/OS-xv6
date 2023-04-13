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
extern uint ticks;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

void
pinit(void)
{
  initQueue(&mlfq.l0);
  initQueue(&mlfq.l1);
  initQueue(&mlfq.l2);
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
  p->state = EMBRYO;
  p->pid = nextpid++;

  p->lev = 0;
  p->tq = 0;
  p->priority = 3;
  p->locked = 0;
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
  int runnable_flag; // L0, L1큐에 RUNNABLE한 프로세스가 남아있는지 확인하는 플래그
  int size; // L0, L1 큐 loop을 위한 size 변수
  int priority_min; // L2 큐 탐색을 위한 변수
  struct proc *now; // L2 큐 탐색을 위한 변수
  
  c->proc = 0;
  for(;;){
    // Enable interrupts on this processor.
    sti();
    acquire(&ptable.lock);

    // MLFQ
    /* schedule process in L0 */
    runnable_flag = 0;
    size = mlfq.l0.count;
    while(size--){
      p = top(&mlfq.l0);
      if(p->state == RUNNABLE){ // RUNNABLE한 프로세스인 경우 switch
        runnable_flag = 1;
        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;

        swtch(&(c->scheduler), p->context);
        switchkvm();
        c->proc = 0;
        // todo: unlock으로 돌아온 경우 detect
        if(!ticks) // priority boosting이 발생한 경우
          break;

        dequeue(&mlfq.l0);
        if(p->lev == 1){ // tq을 다 쓴 프로세스는 l1로 넘겨줌 (이때, state에 대해서는 고려하지 않고, l1에서 처리되도록 함)
          enqueue(&mlfq.l1, p);
          #ifdef DEBUG
          cprintf("L0: Runned - %d\n", p->pid);
          cprintf("0:");printQueue(&mlfq.l0);
          cprintf("1:");printQueue(&mlfq.l1);
          cprintf("2:");printQueue(&mlfq.l2);
          #endif
        }
        else if(p->lev == 0 && p->state != UNUSED && p->state != ZOMBIE){ // tq이 남아 있고 아직 종료되지 않은 프로세스의 경우 l0 큐에 남겨두기 위해 임시저장
          enqueue(&mlfq.l0, p);
        }
      }
      else{ // RUNNABLE한 프로세스가 아닌 경우 switch 하지 않음.
        dequeue(&mlfq.l0);
        if(p->state != UNUSED && p->state != ZOMBIE){
          enqueue(&mlfq.l0, p); // 맨 뒤로 보냄
        }
      }
    }
    if(runnable_flag){
      release(&ptable.lock);
      continue;
    }

    /* schedule process in L1 */
    size = mlfq.l1.count;
    runnable_flag = 0;
    while(size--){ // 가장 앞에 있는 RUNNABLE한 프로세스 찾기
      p = top(&mlfq.l1);
      if(p->state == RUNNABLE){
        runnable_flag = 1;
        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;

        swtch(&(c->scheduler), p->context);
        switchkvm();
        c->proc = 0;
        if(top(&mlfq.l0) == p)
          cprintf("unlocked!\n");
        if(!ticks || top(&mlfq.l0) == p) // priority boosting이 발생한 경우 or unlock 후 돌아온 경우
          break;

        dequeue(&mlfq.l1);
        if(p->lev == 2){ // tq을 다 쓴 프로세스는 dequeue 하고, l2로 넘겨줌
          enqueue(&mlfq.l2, p);
          #ifdef DEBUG
          cprintf("L1: Runned - %d\n", p->pid);
          cprintf("0:");printQueue(&mlfq.l0);
          cprintf("1:");printQueue(&mlfq.l1);
          cprintf("2:");printQueue(&mlfq.l2);
          #endif
        }
        else if(p->lev == 1 && p->state != UNUSED && p->state != ZOMBIE) // tq이 남아 있을 경우 l1 큐에 그대로 남겨 둠
          enqueue(&mlfq.l1, p);
        
        break;
      }
      else{
        dequeue(&mlfq.l1);
        if(p->state != UNUSED && p->state != ZOMBIE)
          enqueue(&mlfq.l1, p); // RUNNABLE로 전환될 여지가 남아 있음, L1의 맨 뒤로 보냄
      }
    }
    /* schedule process in L2 */
    // L1큐에 실행할 프로세스가 없는 경우
    // L2큐를 순회하며 실행할 프로세스 고르기
    // UNUSED 된 프로세스는 priority boosting에서 처리되므로, lev을 확인해서 switching 해 주어야 함
    if(!runnable_flag){
      p = NULL;
      priority_min = 4; // max: 3 이므로 처음 초기화를 위해 4로 설정하고 시작함
      // L2의 프로세스 중 우선순위가 높고 L2에 먼저 들어온 프로세스 찾기
      for(int i = (mlfq.l2.front + 1) % (NPROC + 1); i <= mlfq.l2.rear; i++){
        now = mlfq.l2.q[i];
        if(now->state == RUNNABLE && now->priority < priority_min){
          p = now;
          priority_min = p->priority;
        }
      }
      if(p && p->lev == 2){ // RUNNABLE한 프로세스 중 가장 우선순위가 낮은 프로세스를 찾았다면! // Unlock 이후에 lev이 변경된 프로세스 있을 수 있음
        c->proc = p;
        switchuvm(p);
        p->state = RUNNING;

        swtch(&(c->scheduler), p->context);
        switchkvm();
        c->proc = 0;

        #ifdef DEBUG
        if(p->tq == 0){
          cprintf("L2: Runned - %d\n", p->pid);
          cprintf("0:");printQueue(&mlfq.l0);
          cprintf("1:");printQueue(&mlfq.l1);
          cprintf("2:");printQueue(&mlfq.l2);
        }
        #endif
        
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

// priority boosting
// tq=0, lev=0, priority=3으로 재설정
// 큐 순서를 유지하되 현재 레벨이 높은 순서대로
// UNUSED 된 프로세스 정리
void
priorityBoosting(void)
{
  struct proc *p;
  int size;

  pushcli(); // disable timer interrupts
  acquire(&ptable.lock);
  size = mlfq.l0.count;
  while(size--){
    p = dequeue(&mlfq.l0);
    if(p->state != UNUSED && p->state != ZOMBIE){
      p->tq = 0;
      p->lev = 0;
      p->priority = 3;
      enqueue(&mlfq.l0, p);
    }
  }
  while(!isEmpty(&mlfq.l1)){
    p = dequeue(&mlfq.l1);
    if(p->state != UNUSED && p->state != ZOMBIE){
      p->tq = 0;
      p->lev = 0;
      p->priority = 3;
      enqueue(&mlfq.l0, p);
    }
  }
  while(!isEmpty(&mlfq.l2)){
    p = dequeue(&mlfq.l2);
    if(p->state != UNUSED && p->state != ZOMBIE && p->state != EMBRYO){
      p->tq = 0;
      p->lev = 0;
      p->priority = 3;
      enqueue(&mlfq.l0, p);
    }
  }
  release(&ptable.lock);
  ticks = 0;
  popcli(); // enable timer interrupts
}

// New system calls
int
getLevel(void)
{
  return myproc()->lev;
}

void
setPriority(int pid, int priority)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      p->priority = priority;
      release(&ptable.lock);
      return;
    }
  }
  // invalid pid
  release(&ptable.lock);
  panic("setPriority: Wrong pid!");
}

void
schedulerLock(int password)
{
  struct proc *p;
  struct Queue tmp;

  if(password == PASSWORD){
    if(myproc()->locked)
      return;
    myproc()->locked = 1;
  #ifdef DEBUG
    cprintf("[%d] lock!\n", myproc()->pid);
  #endif
    // mlfq에서 빼기
    // RUNNING 상태이므로 자기 레벨의 큐 가장 앞에 있음
    if(myproc()->lev == 0)
      dequeue(&mlfq.l0);
    else if(myproc()->lev == 1)
      dequeue(&mlfq.l1);
    else if(myproc()->lev == 2){
      while(!isEmpty(&mlfq.l2)){
        p = dequeue(&mlfq.l2);
        if(p != myproc())
          enqueue(&tmp, p);
      }
      while(!isEmpty(&tmp))
        enqueue(&mlfq.l2, dequeue(&tmp));
    }
  #ifdef DEBUG
    cprintf("Removed %d\n", myproc()->pid);
    cprintf("0:");printQueue(&mlfq.l0);
    cprintf("1:");printQueue(&mlfq.l1);
    cprintf("2:");printQueue(&mlfq.l2);
  #endif
    acquire(&tickslock);
    ticks = 0;
    release(&tickslock);
  }
  else{
    cprintf("SchedulerLock: invalid password, pid: %d, time quantum: %d, level: %d\n", myproc()->pid, myproc()->tq, myproc()->lev);
    exit();
  }
}

void
schedulerUnlock(int password)
{
  if(password == PASSWORD){
    if(!myproc()->locked) // 이미 unlock 되어 있는 경우 skip
      return;
    myproc()->lev = 0;
    myproc()->priority = 3;
    myproc()->tq = 0;
    push(&mlfq.l0, myproc());
  #ifdef DEBUG
    cprintf("[%d] unlock!\n", myproc()->pid);
    printQueue(&mlfq.l0);
    printQueue(&mlfq.l1);
    printQueue(&mlfq.l2);
  #endif
    myproc()->locked = 0;
  }
  else{
    cprintf("SchedulerLock: invalid password, pid: %d, time quantum: %d, level: %d\n", myproc()->pid, myproc()->tq, myproc()->lev);
    exit();
  }
}