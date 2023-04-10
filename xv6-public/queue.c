#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
#include "queue.h"
// #define DEBUG


void
initQueue(struct Queue *queue)
{
    queue->front = 0;
    queue->rear = 0;
    queue->count = 0;
    for(int i = 0; i < NPROC + 1; i++){
        queue->q[i] = NULL; // pointer 모두 NULL로 초기화
    }
}

int
isEmpty(struct Queue *queue)
{
    if (queue->front == queue->rear)
        return 1;
    return 0;
}

int
isFull(struct Queue *queue)
{
    if ((queue->rear + 1) % (NPROC + 1) == queue->front)
        return 1;
    return 0;
}

void
enqueue(struct Queue *queue, struct proc *p)
{
    queue->rear = (queue->rear + 1) % (NPROC + 1);
    queue->q[queue->rear] = p;
    queue->count++;
#ifdef DEBUG
  cprintf("[%d] mlfq enqueue\n", p->pid);
#endif
}

struct proc *
dequeue(struct Queue *queue)
{
    if (isEmpty(queue)) // empty queue
        return NULL;
    queue->front = (queue->front + 1) % (NPROC + 1);
    queue->count--;

#ifdef DEBUG
  cprintf("[%d] mlfq dequeue\n", queue->q[queue->front]->pid);
#endif
    
    return queue->q[queue->front];
}