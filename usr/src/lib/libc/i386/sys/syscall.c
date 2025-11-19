#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)syscall.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

extern int errno;

int
syscall(int number, ...)
{
	int result;
	register int arg1 __asm__("ebx");
	register int arg2 __asm__("ecx");
	register int arg3 __asm__("edx");
	register int arg4 __asm__("esi");
	register int arg5 __asm__("edi");

	/* Arguments are already on stack, will be loaded by convention */
	__asm__ volatile (
		"movl	8(%%ebp), %%ebx\n\t"	/* arg1 */
		"movl	12(%%ebp), %%ecx\n\t"	/* arg2 */
		"movl	16(%%ebp), %%edx\n\t"	/* arg3 */
		"movl	20(%%ebp), %%esi\n\t"	/* arg4 */
		"movl	24(%%ebp), %%edi\n\t"	/* arg5 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n"
		"1:\n\t"
		: "=a" (result)
		: "a" (number)
		: "memory", "cc", "ebx", "ecx", "edx", "esi", "edi"
	);

	return result;
}
