/*-
 * Modern C implementation of _setjmp/_longjmp using GNU C inline assembly
 * Replaces legacy assembly file with maintainable C99+ code
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers with inline asm
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)_setjmp.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <setjmp.h>

/*
 * _setjmp() - Save calling environment for later longjmp()
 * Does NOT save signal mask (unlike setjmp)
 *
 * jmp_buf layout for i386 (from setjmp.h):
 *   [0] = return address (PC)
 *   [1] = %ebx
 *   [2] = %esp
 *   [3] = %ebp
 *   [4] = %esi
 *   [5] = %edi
 *
 * Returns: 0 when called directly, non-zero when longjmp returns here
 */
int
_setjmp(jmp_buf env)
{
	int *jmpbuf = (int *)env;

	__asm__ volatile (
		"movl	0(%%esp), %%edx\n\t"	/* Get return address from stack */
		"movl	%%edx, 0(%0)\n\t"	/* Save return address (PC) */
		"movl	%%ebx, 4(%0)\n\t"	/* Save %ebx */
		"movl	%%esp, 8(%0)\n\t"	/* Save %esp */
		"movl	%%ebp, 12(%0)\n\t"	/* Save %ebp */
		"movl	%%esi, 16(%0)\n\t"	/* Save %esi */
		"movl	%%edi, 20(%0)\n\t"	/* Save %edi */
		:			/* no outputs */
		: "r" (jmpbuf)		/* input: jmpbuf address in register */
		: "%edx", "memory"	/* clobbers */
	);

	return 0;
}

/*
 * _longjmp() - Restore environment saved by _setjmp() and return
 *
 * Arguments:
 *   env - jmp_buf saved by _setjmp()
 *   val - value to return (forced to 1 if 0)
 *
 * Never returns to caller - restores stack and jumps to saved return address
 */
void
_longjmp(jmp_buf env, int val)
{
	register int *jmpbuf __asm__("edx") = (int *)env;
	register int retval __asm__("eax") = val;

	/* Ensure val is never 0 (longjmp always returns non-zero) */
	if (retval == 0)
		retval = 1;

	__asm__ volatile (
		"movl	0(%0), %%ecx\n\t"	/* Load return address to %ecx */
		"movl	4(%0), %%ebx\n\t"	/* Restore %ebx */
		"movl	8(%0), %%esp\n\t"	/* Restore %esp */
		"movl	12(%0), %%ebp\n\t"	/* Restore %ebp */
		"movl	16(%0), %%esi\n\t"	/* Restore %esi */
		"movl	20(%0), %%edi\n\t"	/* Restore %edi */
		"jmp	*%%ecx"			/* Jump to saved return address */
		: /* no outputs - function doesn't return */
		: "d" (jmpbuf), "a" (retval)
		: "%ecx", "%esi", "%edi", "%ebx", "memory"
	);

	/* Never reached */
	__builtin_unreachable();
}
