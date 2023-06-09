#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  if(argc != 4 || !(strcmp(argv[1], "-h") || strcmp(argv[1], "-s"))){
    printf(2, "Usage: ln [ -s | -h ] old new\n");
    exit();
  }
  if(!strcmp(argv[1], "-h")){
    if(link(argv[2], argv[3]) < 0) // -h, -s 인자 하나 더 받기
      printf(2, "hard link %s %s: failed\n", argv[2], argv[3]);
  }
  else{
    if(slink(argv[2], argv[3]) < 0)
      printf(2, "symbolic link %s %s: failed\n", argv[2], argv[3]);
  }
  sync();
  exit();
}
