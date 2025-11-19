#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)fork.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

#include <sys/types.h>
#include <unistd.h>

extern int errno;

pid_t
fork(void)
{
	pid_t result;
	int is_child;

	__asm__ volatile (
		"movl	$2, %%eax\n\t"		/* SYS_fork = 2 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n\t"
		"jmp	2f\n"
		"1:\n\t"
		"cmpl	$0, %%edx\n\t"
		"je	2f\n\t"
		"xorl	%%eax, %%eax\n"
		"2:\n\t"
		: "=a" (result), "=d" (is_child)
		:
		: "memory", "cc"
	);

	return result;
}
