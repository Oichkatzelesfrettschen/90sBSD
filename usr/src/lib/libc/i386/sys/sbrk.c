#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)sbrk.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

#include <unistd.h>
#include <stdint.h>

extern int errno;
extern void *curbrk;

void *
sbrk(intptr_t incr)
{
	void *oldbrk = curbrk;
	void *newbrk = (void *)((char *)oldbrk + incr);
	int result;

	__asm__ volatile (
		"movl	%2, %%ebx\n\t"
		"movl	$17, %%eax\n\t"		/* SYS_brk = 17 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n\t"
		"jmp	2f\n"
		"1:\n\t"
		"xorl	%%eax, %%eax\n"
		"2:\n\t"
		: "=a" (result)
		: "b" (newbrk), "r" (newbrk)
		: "memory", "cc"
	);

	if (result < 0)
		return (void *)-1;

	curbrk = newbrk;
	return oldbrk;
}
