#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)sigprocmask.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

#include <signal.h>

extern int errno;

int
sigprocmask(int how, const sigset_t *set, sigset_t *oset)
{
	int result;

	__asm__ volatile (
		"movl	$48, %%eax\n\t"		/* SYS_sigprocmask = 48 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n"
		"1:\n\t"
		: "=a" (result)
		: "b" (how), "c" (set), "d" (oset)
		: "memory", "cc"
	);

	return result;
}
