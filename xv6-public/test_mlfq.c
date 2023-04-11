#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
    for(int i = 0;i < 1000; i++){
        printf(1, "use... tick...\n");
    }
    printf(1, "im done!\n");
    exit();
}