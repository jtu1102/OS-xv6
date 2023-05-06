#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    int pid;

    printf(1, "***** yield test *****\n");
    pid = fork();
    for(int i = 0; i < 10; i++){
        if(pid == 0){
            if(i == 0)
                printf(1, "Child\n");
            yield();
        }
        else{
            if(i == 0)
                printf(1,"Parent\n");
            yield();
            while (wait() != -1)
                sleep(1);
        }
    }

    printf(1, "***** getLevel test *****\n");
    pid = fork();
    for(int i = 0; i < 10; i++){
        if(pid == 0){
            if(i == 0)
                printf(1, "Child\n");
            printf(1, "level: %d\n", getLevel());
        }
        else{
            if(i == 0)
                printf(1, "Parent\n");
            printf(1, "level: %d\n", getLevel());
            while (wait() != -1)
                sleep(1);
        }
    }

    printf(1, "***** setPriority test *****\n");
    pid = fork();
    for(int i = 0; i < 10; i++){
        if(pid == 0){
            if(i == 0){
                printf(1, "Child\n");
                setPriority(getpid(), 0);
            }
        }
        else{
            if(i == 0)
                printf(1,"Parent\n");
            while (wait() != -1)
                sleep(1);
        }
    }
    
    printf(1, "***** schedulerLock/Unlock test *****\n");
    pid = fork();
    for(int i = 0; i < 100; i++){
        if(pid == 0){
            if(i == 0){
                printf(1, "Child\n");
                schedulerLock(2019076880);
            }
            if(i == 99)
                schedulerUnlock(2019076880);
        }
        else{
            if(i == 0)
                printf(1,"Parent\n");
            while (wait() != -1)
                sleep(1);
        }
    }

    exit();
}