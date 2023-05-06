#define NULL 0
struct proc;

struct Queue
{
    int front;
    int rear;
    int count;
    struct proc* q[NPROC + 1]; // full과 empty를 구분하기 위해 +1
};

