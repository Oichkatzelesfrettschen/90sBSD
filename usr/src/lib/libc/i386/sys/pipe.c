/*-
 * Modern C implementation of pipe() - Create pipe
 * Replaces legacy assembly with inline assembly
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)pipe.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* SYSLIBC_SCCS and not lint */

#include <unistd.h>
#include <syscall.h>

extern int errno;

/*
 * pipe() - create pipe (returns two file descriptors)
 *
 * Returns:
 * - On success: 0, with fildes[0] = read end, fildes[1] = write end
 * - On error: -1, errno set
 *
 * The syscall returns read FD in %eax and write FD in %edx
 */
int
pipe(int fildes[2])
{
	register int fd0, fd1, result;

	__asm__ volatile (
		"movl	%3, %%eax\n\t"		/* syscall number */
		"int	$0x80\n\t"		/* make system call */
		"jnc	1f\n\t"			/* jump if no error */
		/* Error path */
		"movl	%%eax, errno\n\t"	/* set errno */
		"movl	$-1, %%eax\n\t"		/* return -1 */
		"xorl	%%edx, %%edx\n\t"	/* clear fd1 */
		"jmp	2f\n"
		"1:\n\t"			/* Success: save FDs, return 0 */
		"movl	%%eax, %%ecx\n\t"	/* save fd0 temporarily */
		"movl	$0, %%eax\n\t"		/* return value = 0 */
		"movl	%%ecx, %%ebx\n"		/* fd0 to output register */
		"2:\n\t"
		: "=a" (result), "=d" (fd1), "=b" (fd0)
		: "i" (SYS_pipe)
		: "memory", "cc", "ecx"
	);

	if (result == 0) {
		fildes[0] = fd0;	/* read end */
		fildes[1] = fd1;	/* write end */
	}

	return result;
}
