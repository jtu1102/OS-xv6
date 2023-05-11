#include "types.h"
#include "stat.h"
#include "user.h"

#define NUM_THREAD 10

int global;
thread_t thread[NUM_THREAD];
int expected[NUM_THREAD];

void *routine_basic(void *arg)
{
  int val = (int)arg;
  printf(1, "Thread %d start\n", val);
  if (val == 1) {
    sleep(200);
    global = 1;
  }
  printf(1, "Thread %d end\n", val);
  thread_exit(arg);
  return 0;
}

void *routine_fork(void *arg)
{
  int val = (int)arg;
  int pid;

  printf(1, "Thread %d start\n", val);
  pid = fork();
  if (pid < 0) {
    printf(1, "Fork error on thread %d\n", val);
    exit();
  }

  if (pid == 0) {
    printf(1, "Child of thread %d start\n", val);
    sleep(100);
    global = 3; // child process의 전역변수 메모리 영역은 부모 프로세스와 분리되어 있음
    printf(1, "Child of thread %d end\n", val);
    exit();
  }
  else {
    global = 2;
    if (wait() == -1) { // fork 1번 했으니 wait() 도 한번만 호출해도 됨
      printf(1, "Thread %d lost their child\n", val);
	  exit();
    }
  }
  printf(1, "Thread %d end\n", val);
  thread_exit(arg);
  return 0;
}

void create_all(int n, void *(*entry)(void *))
{
  int i;
  for (i = 0; i < n; i++) {
    if (thread_create(&thread[i], entry, (void *)i) != 0) {
      printf(1, "Error creating thread %d\n", i);
      exit();
    }
  }
}

void join_all(int n)
{
  int i, retval;
  for (i = 0; i < n; i++) {
    if (thread_join(thread[i], (void **)&retval) != 0) {
      printf(1, "Error joining thread %d\n", i);
      exit();
    }
    if (retval != expected[i]) {
      printf(1, "Thread %d returned %d, but expected %d\n", i, retval, expected[i]);
      exit();
    }
  }
}

int main(int argc, char *argv[])
{
  int i;
  for (i = 0; i < NUM_THREAD; i++)
    expected[i] = i;

  printf(1, "Test 1: Basic test\n");
  create_all(5, routine_basic);
  sleep(100);
  printf(1, "main thread waiting for other threads...\n");
  join_all(5);
  if (global != 1) {
    printf(1, "join returned before thread exit, or the address space is not properly shared\n");
    exit();
  }
  printf(1, "Test 1 passed\n\n");

  printf(1, "Test 2: Fork test\n");
  create_all(NUM_THREAD, routine_fork);
  join_all(NUM_THREAD);
  if (global != 2) {
    if (global == 3) {
      printf(1, "child process referenced parent's memory\n");
    }
    else {
      printf(1, "global expected 2, found %d\n", global);
    }
    exit();
  }
  printf(1, "Test 2 passed\n\n");

  exit();
}
