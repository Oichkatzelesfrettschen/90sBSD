/*-
 * Modern C implementation of brk() - Set program break
 * Replaces legacy assembly with inline assembly
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)brk.c	5.3 (Berkeley Modernized) 11/19/25";
#endif /* SYSLIBC_SCCS and not lint */

#include <unistd.h>
#include <syscall.h>

extern int errno;
extern char end[];	/* End of BSS segment from linker */

/* Shared state for brk/sbrk */
void *minbrk = (void *)end;
void *curbrk = (void *)end;

/*
 * _brk() - internal brk implementation without bounds checking
 */
int
_brk(void *addr)
{
	register int result;

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
		: "i" (SYS_brk), "D" (addr)	/* %edi = addr for syscall */
		: "memory", "cc"
	);

	if (result == 0)
		curbrk = addr;

	return result;
}

/*
 * brk() - set program break with bounds checking
 *
 * Returns:
 * - 0 on success
 * - -1 on error, errno set
 */
int
brk(void *addr)
{
	/* Enforce minimum break */
	if (addr < minbrk)
		addr = minbrk;

	return _brk(addr);
}
