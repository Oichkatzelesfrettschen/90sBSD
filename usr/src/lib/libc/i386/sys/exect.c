#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)exect.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

#include <unistd.h>

extern int errno;
#define PSL_T 0x100  /* Trace bit from machine/psl.h */

int
exect(const char *path, char *const argv[], char *const envp[])
{
	int result;
	int eflags;

	/* Get current EFLAGS, set trace bit, execute syscall */
	__asm__ volatile (
		"pushf\n\t"
		"popl	%%edx\n\t"
		"orl	%4, %%edx\n\t"		/* Set PSL_T (trace bit) */
		"pushl	%%edx\n\t"
		"popf\n\t"
		"movl	$59, %%eax\n\t"		/* SYS_execve = 59 */
		"int	$0x80\n\t"
		"movl	%%eax, errno\n\t"	/* execve only returns on error */
		"movl	$-1, %%eax\n"
		: "=a" (result)
		: "b" (path), "c" (argv), "d" (envp), "i" (PSL_T)
		: "memory", "cc"
	);

	return result;
}
