#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    int pid;
    pid=fork();
    for(int i = 0; i < 10; i++){
        if(pid == 0){
            printf(1, "Child\n");
            yield();
        }
        else{
            printf(1,"Parent\n");
            yield();
        }
    }
    if (pid > 0)
        wait(); // 자식 프로세스가 zombie 되지 않도록 wait()
    exit();
}