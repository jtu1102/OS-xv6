#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

#define BSIZE 512
#define NINDIRECT (BSIZE / sizeof(uint)) // 128
#define NDBLINDIRECT ((NINDIRECT) * (NINDIRECT)) // 16384
#define NTRPLDIRECT ((NINDIRECT) * (NINDIRECT) * (NINDIRECT)) // 2097152
#define NUM_BYTES (NINDIRECT * BSIZE) // 65KB
#define NUM_BYTES1 ((NINDIRECT + 10000) * (BSIZE)) // 5MB
#define NUM_BYTES2 ((NDBLINDIRECT + 10000) * (BSIZE)) // 13.5MB
#define NUM_TRPL_BYTES ((NTRPLDIRECT) * (BSIZE))

char buf[NUM_BYTES], buf1[NUM_BYTES1], buf2[NUM_BYTES2];
char filename[16] = "test.txt";

void failed(const char *msg)
{
  printf(1, msg);
  printf(1, "Test failed!!\n");
  exit();
}

void test1()
{
  int fd;

  printf(1, "Test 1: Write %d bytes\n", NUM_BYTES);
  fd = open(filename, O_CREATE | O_WRONLY);
  if (fd < 0)
    failed("File open error\n");
  if (write(fd, buf, NUM_BYTES) < 0)
    failed("File write error\n");
  if (close(fd) < 0)
    failed("File close error\n");
  printf(1, "Test 1 passed\n\n");
}

void test2()
{
  int fd;

  printf(1, "Test 2: Write %d bytes\n", NUM_BYTES1);
  fd = open(filename, O_CREATE | O_WRONLY);
  if (fd < 0)
    failed("File open error\n");
  if (write(fd, buf1, NUM_BYTES1) < 0)
    failed("File write error\n");
  if (close(fd) < 0)
    failed("File close error\n");
  printf(1, "Test 2 passed\n\n");
}

void test3()
{
  int fd;

  printf(1, "Test 3: Write %d bytes\n", NUM_BYTES2);
  fd = open(filename, O_CREATE | O_WRONLY);
  if (fd < 0)
    failed("File open error\n");
  if (write(fd, buf2, NUM_BYTES2) < 0)
    failed("File write error\n");
  if (close(fd) < 0)
    failed("File close error\n");
  printf(1, "Test 3 passed\n\n");
}

int main(int argc, char *argv[])
{
  int i;
  for (i = 0; i < NUM_BYTES; i++)
    buf[i] = (i % 26) + 'a';
  for (i = 0; i < NUM_BYTES1; i++)
    buf1[i] = (i % 26) + 'a';
  for (i = 0; i < NUM_BYTES2; i++)
    buf2[i] = (i % 26) + 'a';

  test1();
  test2();
  test3();
  
  printf(1, "All tests passed!!\n");
  exit();
}
