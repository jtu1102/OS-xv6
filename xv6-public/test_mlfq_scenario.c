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

int
main(int argc, char **argv)
{
  int p;
  int pid;

  printf(1, "MLFQ scenario test\n");

  printf(1, "Test1\n");
  p = create_child(3);
  if (!p) {
    pid = getpid();
    setPriority(pid, pid % 4);
    for (int i = 0; i < NUM_LOOP; i++){
      if(!(i % 1000))
        printf(1, "process %d, lev%d\n", pid, getLevel());
    }
    printf(1, "process %d Done\n", pid);
    exit();
  }
  else{
    while (wait() != -1)
      sleep(1);
  }

  printf(1, "Test2, schedulerLock\n");
  p = create_child(6);
  if(!p) {
    pid = getpid();
    int cnt[3];
    if(pid % 6 == 0){
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(PASSWORD);
      for (int i = 0; i < 50; i++){ // Unlock in user process (100 tick 이내에 룹 종료)
        cnt[getLevel()]++;
      }
      schedulerUnlock(PASSWORD);
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

    else if(pid % 6 == 1){
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(2019076881); // wrong password
      for (int i = 0; i < NUM_LOOP; i++){
        cnt[getLevel()]++;
      }
      schedulerUnlock(PASSWORD);
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

    else if(pid % 6 == 2){
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(PASSWORD);
      for (int i = 0; i < 50; i++){
        cnt[getLevel()]++;
      }
      schedulerUnlock(2019076881); // wrong password
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

    else if(pid % 6 == 3){
      cnt[0] = cnt[1] = cnt[2] = 0;
      schedulerLock(PASSWORD);
      for (int i = 0; i < NUM_LOOP; i++){ // priority boosting 에 의해 unlock
        cnt[getLevel()]++;
      }
      schedulerUnlock(2019076881); // wrong password unlock 이후 password 오류 -> 에러로 처리
      printf(1, "process %d Done, cnt: %d, %d, %d\n", pid, cnt[0], cnt[1], cnt[2]);
    }

    else if(pid % 6 == 4){
      cnt[0] = cnt[1] = cnt[2] = 0;
      for (int i = 0; i < NUM_LOOP / 2; i++){
        cnt[getLevel()]++;
      }
      schedulerLock(PASSWORD); // 한참 실행 중에 lock 되는 경우
      for (int i = 0; i < NUM_LOOP / 2; i++){
        cnt[getLevel()]++;
      }
      schedulerUnlock(PASSWORD); // wrong password unlock 이후 password 오류 -> 에러로 처리
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
    exit();
  }
  else{
    while (wait() != -1)
        sleep(1);
  }

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
    exit();
  }
  else{
    while (wait() != -1)
      sleep(1);
  }

  exit();
}
