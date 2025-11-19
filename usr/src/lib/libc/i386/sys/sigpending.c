#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)sigpending.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

#include <signal.h>

extern int errno;

int
sigpending(sigset_t *set)
{
	int result;

	__asm__ volatile (
		"movl	$52, %%eax\n\t"		/* SYS_sigpending = 52 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n"
		"1:\n\t"
		: "=a" (result)
		: "b" (set)
		: "memory", "cc"
	);

	return result;
}
