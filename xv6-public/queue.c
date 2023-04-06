#define NULL 0

typedef struct node {
    struct proc *p;
    struct node *next;
} node;

typedef struct Queue
{
    node *front;
    node *rear;
    int count;
} Queue;

void
initQueue(Queue *queue)
{
    queue->front = queue->rear = NULL; 
    queue->count = 0;
}

int
isEmpty(Queue *queue)
{
    return queue->count == 0;
}

void
enqueue(Queue *queue, struct proc *p)
{
    node *new = (node *)malloc(sizeof(node));
    
    new->p = p;
    new->next = NULL;

    if (isEmpty(queue))
        queue->front = new;
    else
        queue->rear->next = new;
    queue->rear = new;
    queue->count++;
}

struct proc *
dequeue(Queue *queue)
{
    struct proc *p;
    node *ptr;

    if (isEmpty(queue)) // empty queue
        return NULL;
    ptr = queue->front;
    p = ptr->p;
    queue->front = ptr->next;
    free(ptr);
    (queue->count)--;

    return p;
}