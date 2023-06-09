// process manager
// shell-like..
#include "types.h"
#include "user.h"
#include "fcntl.h"

#define NPROC 64
struct ps {
  int active;         // # of running & runnable processes
  struct info {       // information of process
    uint sz;
    int pid;
    int stacksz;
    int mlimit;
    char name[16];
  } info[NPROC];
} pstatus;

int
getcmd(char *buf, int nbuf)
{
    printf(2, "> ");
    memset(buf, 0, nbuf);
    gets(buf, nbuf);
    if(buf[0] == 0) // EOF
      return -1;
    return 0;
}

void
panic(char *s)
{
  printf(2, "%s\n", s);
  exit();
}

int
fork1(void)
{
    int pid;

    pid = fork();
    if(pid == -1)
      panic("fork");
    return pid;
}

void
parsecmd(char *s, char **cmd)
{
    char *ptr;
    int i;

    for(i = 0; i < 3; i++){
        ptr = strchr(s, ' ');
        strcpy(cmd[i], s);
        cmd[i][ptr - s] = 0;
        if(!ptr)
            break;
        s = ++ptr;
    }
    if(i < 3)
        cmd[++i][0] = 0;
    else
        cmd[3][0] = 0;
}

// print process info
// 1. process name
// 2. process pid
// 3. process stack page number -> 프로세스의 스택용 페이지 수, 스레드의 스택 페이지 수는 고려하지 않음
// 4. allocated memory size -> sz는 모든 스레드에서 같은 값으로 공유하도록 유지됨
// 5. memory limit -> 모두 공유. 출력하면 됨
void
runlist(void)
{
    int i;

    process_status(&pstatus);
    for(i = 0; i < pstatus.active; i++){
        printf(1, "");
        printf(1, "[PID: %d] Process Name: %s\n", pstatus.info[i].pid, pstatus.info[i].name);
        printf(1, "  Allocated Memory Size: %d\n", pstatus.info[i].sz);
        printf(1, "  Stack Page: %d\n", pstatus.info[i].stacksz);
        printf(1, "  Memory Limit: %d\n", pstatus.info[i].mlimit);
    }
}

void
runkill(char *strpid)
{
    int pid;
    
    pid = atoi(strpid);
    if (kill(pid) < 0)
        panic("kill error!");
    printf(1, "process %d successfully killed\n", pid);
}

void
runexec(char *path, char *strstacksize)
{
    int stacksize;
    char *argv[2];

    argv[0] = path;
    argv[1] = 0;
    stacksize = atoi(strstacksize);
    if(fork1() == 0){
        if(path == 0 || exec2(path, argv, stacksize) < 0){
            printf(2, "execute %s failed\n", path);
            exit();
        }
    }
}

void
runmemlim(char *strpid, char *strlimit)
{
    int pid;
    int limit;

    pid = atoi(strpid);
    limit = atoi(strlimit);
    if(setmemorylimit(pid, limit) < 0)
        panic("memlim error!");
    printf(1, "memory limit of process %d successfully set to %d\n", pid, limit);
}

void
runcmd(char **cmd)
{
    if(!strcmp(cmd[0], "list"))
        runlist();
    else if(!strcmp(cmd[0], "kill"))
        runkill(cmd[1]);
    else if(!strcmp(cmd[0], "execute"))
        runexec(cmd[1], cmd[2]);
    else if(!strcmp(cmd[0], "memlim"))
        runmemlim(cmd[1], cmd[2]);
}

int
main(void)
{
    static char buf[100];
    char **cmd;
    int i;

    cmd = (char **)malloc(sizeof(char *) * 4);
    for(i = 0; i < 4; i++)
        cmd[i] = (char *)malloc(sizeof(char) * 100);
    // Read and run input commands.
    while(getcmd(buf, sizeof(buf)) >= 0){
        buf[strlen(buf)-1] = 0; // chop \n
        if(!strcmp(buf, "exit")) {
            break;
        }
        if(fork1() == 0) {
            parsecmd(buf, cmd);
            runcmd(cmd);
            exit();
        }
        else
            wait();
    }
    for(i = 0; i < 4; i++)
        free(cmd[i]);
    free(cmd);
    exit();
}