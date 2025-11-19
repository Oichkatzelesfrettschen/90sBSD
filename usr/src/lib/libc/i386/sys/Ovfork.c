#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)Ovfork.c	5.2 (Berkeley Modernized) 11/19/25";
#endif

#include <sys/types.h>
#include <unistd.h>

extern int errno;

pid_t
vfork(void)
{
	pid_t result;
	int err;

	__asm__ volatile (
		"movl	$66, %%eax\n\t"
		"int	$0x80\n\t"
		"jnc	1f\n\t"
		"movl	$-1, %%edx\n\t"
		"jmp	2f\n"
		"1:\n\t"
		"xorl	%%edx, %%edx\n"
		"2:\n\t"
		: "=a" (result), "=d" (err)
		:
		: "memory", "cc"
	);

	if (err) {
		errno = (int)result;
		return -1;
	}

	/* Check if child - %edx was 1 in child, now cleared */
	__asm__ volatile (
		"cmpl	$0, %%edx\n\t"
		"je	1f\n\t"
		"xorl	%%eax, %%eax\n"
		"1:\n\t"
		: "=a" (result)
		:
		: "edx"
	);

	return result;
}
