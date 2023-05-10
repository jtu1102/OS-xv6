#include "types.h"
#include "stat.h"
#include "user.h"

void * thread_main(void *i)
{
    printf(1, "thread id : %d\n", (int)i);
    return (void *)i;
}

int
main(int argc, char *argv[])
{
    int i;
	int rc;
	// int status;
    thread_t threads[1];
	
	printf(1, "pid=%d\n", getpid());
	
	for (i = 0; i < 1; i++)
	{	
		// done[i] = 0;
		rc = thread_create(&threads[i], &thread_main, (void *)i);
		printf(1, "%d, %d, return: %d\n", (int)i, (int)threads[i], rc);
	}

	// for (i = 4; i >= 0; i--)
	// {
	// 	// done[i] = 1;
	//     rc = thread_join(threads[i], (void **)&status);
	// 	if (rc == 0)
	// 	{
	// 		printf("Completed join with thread %d status= %d\n",i, status);
	// 	}
	// 	else
	// 	{
	// 		printf("ERROR; return code from pthread_join() is %d, thread %d\n", rc, i);
    //      		         return -1;
	// 	}
	// }
    exit();
}
