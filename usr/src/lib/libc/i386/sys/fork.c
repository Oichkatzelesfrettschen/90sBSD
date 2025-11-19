/*-
 * Modern C implementation of fork() - Create new process
 * Replaces legacy assembly with inline assembly
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)fork.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* SYSLIBC_SCCS and not lint */

#include <sys/types.h>
#include <unistd.h>
#include <syscall.h>

extern int errno;

/*
 * fork() - create child process
 *
 * Returns:
 * - Parent: child's PID in %eax
 * - Child: 0 in %eax
 * - %edx distinguishes parent (0) from child (1)
 */
pid_t
fork(void)
{
	register int result;
	register int is_child;

	__asm__ volatile (
		"movl	%2, %%eax\n\t"		/* syscall number */
		"int	$0x80\n\t"		/* make system call */
		"jnc	1f\n\t"			/* jump if no error */
		/* Error path */
		"movl	%%eax, errno\n\t"	/* set errno */
		"movl	$-1, %%eax\n\t"		/* return -1 */
		"jmp	2f\n"
		"1:\n\t"			/* Success - check parent/child */
		"cmpl	$0, %%edx\n\t"		/* %edx == 0 in parent, 1 in child */
		"je	2f\n\t"			/* parent: keep child PID */
		"xorl	%%eax, %%eax\n"		/* child: return 0 */
		"2:\n\t"
		: "=a" (result), "=d" (is_child)
		: "i" (SYS_fork)
		: "memory", "cc"
	);

	return (pid_t)result;
}
