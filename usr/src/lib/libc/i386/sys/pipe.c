#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)pipe.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

#include <unistd.h>

extern int errno;

int
pipe(int fildes[2])
{
	int fd0, fd1;
	int result;

	__asm__ volatile (
		"movl	$42, %%eax\n\t"		/* SYS_pipe = 42 */
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	%%eax, errno\n\t"
		"movl	$-1, %%eax\n\t"
		"xorl	%%edx, %%edx\n\t"
		"jmp	2f\n"
		"1:\n\t"
		"movl	%%eax, %%ecx\n\t"
		"movl	$0, %%eax\n"
		"2:\n\t"
		: "=a" (result), "=d" (fd1), "=c" (fd0)
		:
		: "memory", "cc", "ebx"
	);

	if (result == 0) {
		fildes[0] = fd0;
		fildes[1] = fd1;
	}
	return result;
}
