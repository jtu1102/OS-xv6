#include "types.h"
#include "stat.h"
#include "user.h"

// test for prac syscall
int
main(int argc, char *argv[])
{
	if (argc <= 1){
		exit();
	}
	if (strcmp(argv[1],"\"user\"")!=0){
		exit();
	}

	char *buf = "Hello xv6!";
	int ret_val;
	ret_val = myfunction(buf);
	printf(1, "Return value : 0x%x\n", ret_val);
	exit();
}
