#include "types.h"
#include "stat.h"
#include "user.h"

#define NUM_CHILD 3
#define NUM_LOOP 50000
#define PASSWORD 2019076880

int create_child(void) {
  for (int i = 0; i < NUM_CHILD; i++) {
    int pid = fork();
    if (pid == 0) {
      sleep(10);
      return 0; // child
    }
  }
  return 1; // parent
}

void exit_child(int parent) {
  if (parent)
    while (wait() != -1);
  else
    exit();
}

int
main(int argc, char **argv)
{
  int p;
  int pid;

  printf(1, "MLFQ scenario test\n");

  printf(1, "Test1\n");
  p = create_child();
  if (!p) {
    pid = getpid();
    for (int i = 0; i < NUM_LOOP; i++){
      // printf(1, "process %d, lev%d\n", pid, getLevel());
      getLevel();
    }
    printf(1, "process %d Done\n", pid);
  }
  exit_child(p);

  printf(1, "Test2, schedulerLock\n");
  p = create_child();
  if(!p) {
    pid = getpid();
    int cnt[3];
    cnt[0] = cnt[1] = cnt[2] = 0;
    schedulerLock(PASSWORD);
    for (int i = 0; i < NUM_LOOP; i++){
      cnt[getLevel()]++;
    }
    printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    schedulerUnlock(PASSWORD);
  }
  exit_child(p);

  exit();
}