#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)ptrace.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

#include <sys/types.h>

extern int errno;

int
ptrace(int request, pid_t pid, caddr_t addr, int data)
{
	int result;

	errno = 0;  /* ptrace uses errno=0 to distinguish real 0 return from error */
	
	__asm__ volatile (
		"movl	$26, %%eax\n\t"		/* SYS_ptrace = 26 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n"
		"1:\n\t"
		: "=a" (result)
		: "b" (request), "c" (pid), "d" (addr), "S" (data)
		: "memory", "cc"
	);

	return result;
}
