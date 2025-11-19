#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)reboot.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

extern int errno;

int
reboot(int howto)
{
	int result;

	__asm__ volatile (
		"movl	$55, %%eax\n\t"		/* SYS_reboot = 55 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n"
		"1:\n\t"
		: "=a" (result)
		: "b" (howto)
		: "memory", "cc"
	);

	return result;
}
