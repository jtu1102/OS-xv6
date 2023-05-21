#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[])
{
  int cnt;

  cnt = 0;
  printf(1, "background process %d start\n", getpid());
  while(1){
    cnt++; // infinite loop
  }
  exit();
}
