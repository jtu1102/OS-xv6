#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    printf(1, "***** yield test *****\n");
    int pid;

    pid = fork();
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

    printf(1, "***** getLevel test *****\n");

    printf(1, "***** setPriority test *****\n");
    
    printf(1, "***** schedulerLock/Unlock test *****\n");
    
    exit();
}