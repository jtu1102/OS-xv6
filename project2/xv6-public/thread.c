#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "thread.h"


int
thread_create(thread_t *thread, void *(*start_routine)(void *), void *arg)
{
    int i;
    uint sz, sp, ustack[3];
    struct proc *nt, *p;
    struct proc *curproc = myproc();

    // Allocate thread
    if((nt = allocproc()) == 0){
        return -1;
    }
    nt->pid = curproc->pid;
    nt->pgdir = curproc->pgdir; // share text, data, heap memory with main thread
    nt->sz = curproc->sz;
    nt->parent = curproc->parent; // (?) thread의 부모 프로세스는 생성 프로세스의 부모 프로세스를 따라가기.. 어디서 생성되었는지는 pid를 보면 알 수 있으니까
    *nt->tf = *curproc->tf;

    nt->isThread = 1;
    nt->tid = curproc->nexttid++;
    
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
        if(p->pid == curproc->pid)
            p->nexttid = curproc->nexttid;
    release(&ptable.lock);
    // nt->tf->eax = 0; // start_routine에서 알아서 처리 될 거니까 추가 안 해도 될듯. 아 확신은 없다 근뎁
    
    for(i = 0; i < NOFILE; i++)
        if(curproc->ofile[i])
            nt->ofile[i] = filedup(curproc->ofile[i]); // filedup, idup는 단순히 ref (reference 인듯?) 개수를 1씩 증가시켜주는 거니까.. 이렇게 해도 될듯
    nt->cwd = idup(curproc->cwd);

    // allocate user stack
    sz = nt->sz;
    if((sz = allocuvm(nt->pgdir, sz, sz + 2*PGSIZE)) == 0)
        return -1;
    clearpteu(nt->pgdir, (char*)(sz - 2*PGSIZE));
    sp = sz;
    nt->sz = sz;
    
    // todo: arg setting
    // Push argument strings, prepare rest of stack in ustack.
    ustack[2] = 0;
    ustack[1] = (uint)arg; // argument of start_routine
    ustack[0] = 0xffffffff; // fake return PC

    sp -= 3 * 4;
    if(copyout(nt->pgdir, sp, ustack, 3*4) < 0)
        return -1;
    nt->tf->esp = sp;

    safestrcpy(nt->name, curproc->name, sizeof(curproc->name));

    nt->tf->eip = (uint)start_routine; // (?) allocproc에서 forkret 실행시키는거 따라함..
    // switchuvm...... 해 줘야 하나? 휴.. ㅜㅜㅜ어렵다
    switchuvm(nt);
    acquire(&ptable.lock);
    nt->state = RUNNABLE;
    release(&ptable.lock);

    *thread = nt->tid;
    
    return 0;
}