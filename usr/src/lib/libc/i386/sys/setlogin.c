#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)setlogin.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

extern int errno;

int
setlogin(const char *name)
{
	int result;

	__asm__ volatile (
		"movl	$50, %%eax\n\t"		/* SYS_setlogin = 50 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n"
		"1:\n\t"
		: "=a" (result)
		: "b" (name)
		: "memory", "cc"
	);

	return result;
}
