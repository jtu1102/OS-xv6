#include "types.h"
#include "stat.h"
#include "user.h"

#define NUM_LOOP 30000
#define PASSWORD 2019076880

int create_child(int num_child) {
  for (int i = 0; i < num_child; i++) {
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
  else{
    printf(1, "go exit: %d\n", getpid());
    exit();
  }
}

int
main(int argc, char **argv)
{
  int p;
  int pid;

  printf(1, "MLFQ scenario test\n");

  // printf(1, "Test1\n");
  // p = create_child(3);
  // if (!p) {
  //   pid = getpid();
  //   for (int i = 0; i < NUM_LOOP; i++){
  //     // printf(1, "process %d, lev%d\n", pid, getLevel());
  //     getLevel();
  //   }
  //   printf(1, "process %d Done\n", pid);
  // }
  // exit_child(p);

  printf(1, "Test2, schedulerLock\n");
  p = create_child(5);
  if(!p) {
    pid = getpid();
    int cnt[3];
    if(pid % 5 == 0){
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(PASSWORD);
      for (int i = 0; i < 50; i++){ // Unlock in user process (100 tick 이내에 룹 종료)
        cnt[getLevel()]++;
      }
      schedulerUnlock(PASSWORD);
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

    else if(pid % 5 == 1){
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(2019076881); // wrong password
      for (int i = 0; i < NUM_LOOP; i++){
        cnt[getLevel()]++;
      }
      schedulerUnlock(PASSWORD);
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

    else if(pid % 5 == 2){
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(PASSWORD);
      for (int i = 0; i < 50; i++){
        cnt[getLevel()]++;
      }
      schedulerUnlock(2019076881); // wrong password
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

    else if(pid % 5 == 3){
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(PASSWORD);
      for (int i = 0; i < NUM_LOOP; i++){ // priority boosting 에 의해 unlock
        cnt[getLevel()]++;
      }
      schedulerUnlock(2019076881); // wrong password unlock 이후 password 오류 -> 에러로 처리
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

    else{
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(PASSWORD);
      for (int i = 0; i < NUM_LOOP; i++){ // priority boosting 에 의해 unlock
        cnt[getLevel()]++;
      }
      schedulerUnlock(PASSWORD);
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

  }
  exit_child(p);

  printf(1, "Test3, schedulerLock by interrupts\n");
  p = create_child(2);
  if(!p) {
    pid = getpid();
    int cnt[3];
    cnt[0] = cnt[1] = cnt[2] = 0;
    __asm__("int $129"); // schedulerLock
    for (int i = 0; i < NUM_LOOP; i++){
      cnt[getLevel()]++;
    }
    printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    __asm__("int $130"); // schedulerUnlock
  }
  exit_child(p);

  exit();
}