/*-
 * Modern C implementation of sbrk() - Increment program break
 * Replaces legacy assembly with inline assembly
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)sbrk.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* SYSLIBC_SCCS and not lint */

#include <unistd.h>
#include <syscall.h>
#include <stdint.h>

extern int errno;
extern void *curbrk;

/*
 * sbrk() - increment program break by given amount
 *
 * Returns:
 * - Previous break value on success
 * - (void *)-1 on error, errno set
 */
void *
sbrk(intptr_t incr)
{
	void *oldbrk = curbrk;
	void *newbrk = (void *)((char *)oldbrk + incr);
	register int result;

	/* Make brk syscall with new break address */
	__asm__ volatile (
		"movl	%1, %%eax\n\t"		/* syscall number */
		"int	$0x80\n\t"		/* make system call */
		"jnc	1f\n\t"			/* jump if no error */
		/* Error path */
		"movl	%%eax, errno\n\t"	/* set errno */
		"movl	$-1, %%eax\n\t"		/* return -1 */
		"jmp	2f\n"
		"1:\n\t"			/* Success */
		"xorl	%%eax, %%eax\n"		/* return 0 */
		"2:\n\t"
		: "=a" (result)
		: "i" (SYS_brk), "D" (newbrk)
		: "memory", "cc"
	);

	if (result < 0)
		return (void *)-1;

	/* Update current break and return old value */
	curbrk = newbrk;
	return oldbrk;
}
