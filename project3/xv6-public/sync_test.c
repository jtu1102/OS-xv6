#include "types.h"
#include "stat.h"
#include "user.h"
#include "fcntl.h"

#define BSIZE 512
#define NUM_BYTES (10 * BSIZE) // 65KB

char buf[NUM_BYTES];
char filename[16] = "test.txt";
char filename2[16] = "test2.txt";

void failed(const char *msg)
{
  printf(1, msg);
  printf(1, "Test failed!!\n");
  exit();
}

void test1()
{
  int fd;

  printf(1, "Test 1: Write %d bytes with sync\n", NUM_BYTES);
  fd = open(filename, O_CREATE | O_WRONLY);
  if (fd < 0)
    failed("File open error\n");
  if (write(fd, buf, NUM_BYTES) < 0)
    failed("File write error\n");
  sync();
  if (close(fd) < 0)
    failed("File close error\n");
  printf(1, "Test 1 file write done\n\n");
}

void test2()
{
  int fd;

  printf(1, "Test 2: Write %d bytes without sync\n", NUM_BYTES);
  fd = open(filename2, O_CREATE | O_WRONLY);
  if (fd < 0)
    failed("File open error\n");
  if (write(fd, buf, NUM_BYTES) < 0)
    failed("File write error\n");
  if (close(fd) < 0)
    failed("File close error\n");
  printf(1, "Test 2 file write done\n\n");
}

int main(int argc, char *argv[])
{
  int i;
  for (i = 0; i < NUM_BYTES; i++)
    buf[i] = (i % 26) + 'a';

  test1();
  test2();
  
  printf(1, "please reboot xv6 and check test2.txt \n");
  exit();
}
