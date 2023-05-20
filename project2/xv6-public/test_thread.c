#include "types.h"
#include "stat.h"
#include "user.h"

#define NUM_THREAD 10
#define PAGESZ 4096

int global;
thread_t thread[NUM_THREAD];
int expected[NUM_THREAD]; // expected retval

void *routine_basic(void *arg)
{
  int val = (int)arg;
  printf(1, "Thread %d start\n", val);
  if (val == 1) {
    sleep(200);
    global = 1;
  }
  if (val == 2) {
    printf(1, "tid 2 - i changed val to 1000\n");
    val = 1000;
    yield();
  }
  printf(1, "val: %d\n", val);
  printf(1, "Thread %d end\n", (int)arg);
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

int *ptr;

void *thread_sbrk(void *arg)
{
  int i;

  printf(1, "Thread %d start\n", (int)arg);

  if ((int)arg == 0) {
    ptr = (int *)malloc(PAGESZ * 16); // 16개 페이지 공간 할당 (4096 * 16)
    printf(1,"malloc done\n");
	sleep(100);
  }
  else {
    while (ptr == 0) // 첫번째 스레드에서 메모리 할당 해 줄 때까지 대기
      sleep(1);
    for (i = 0; i < PAGESZ * 16 / 4; i++) // int는 4byte (65536 / 4 = 16384)
      ptr[i] = 25; // 내나이 스물다섯..
  }
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
  create_all(NUM_THREAD, routine_basic);
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
  
  printf(1, "Test 3: Sbrk test\n");
  create_all(NUM_THREAD, thread_sbrk);
  join_all(NUM_THREAD);
  for(i = 0; i < PAGESZ * 16 / 4; i++){
	if(ptr[i] != 25){
		printf(1, "shared memory cannot accessable in all thread");
		exit();
	}
  }
  free(ptr);
  ptr = 0;
  printf(1, "Test 3 passed\n\n");

  exit();
}
