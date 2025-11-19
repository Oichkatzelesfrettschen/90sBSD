#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)sigreturn.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

struct sigcontext;

extern int errno;

int
sigreturn(struct sigcontext *scp)
{
	int result;

	__asm__ volatile (
		"movl	$103, %%eax\n\t"	/* SYS_sigreturn = 103 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n"
		"1:\n\t"
		: "=a" (result)
		: "b" (scp)
		: "memory", "cc"
	);

	return result;
}
