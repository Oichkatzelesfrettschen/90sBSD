#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)brk.c	5.3 (Berkeley Modernized) 11/19/25";
#endif

#include <unistd.h>

extern int errno;
extern char end[];
char *minbrk = (char *)&end;
char *curbrk = (char *)&end;

char *
_brk(const char *addr)
{
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
		: "b" (addr), "r" (addr)
		: "memory", "cc"
	);

	if (result == 0) {
		curbrk = (char *)addr;
		return curbrk;
	}
	return (char *)-1;
}

char *
brk(const char *addr)
{
	if (addr < minbrk)
		addr = minbrk;
	return _brk(addr);
}
