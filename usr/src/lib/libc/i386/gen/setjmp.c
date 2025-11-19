/*-
 * Modern C implementation of setjmp()/longjmp() - Non-local jumps with signal mask
 * Replaces legacy x87 assembly with C99 standard implementation
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)setjmp.c	5.1 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <setjmp.h>
#include <signal.h>

/*
 * Save context and signal mask for non-local goto
 * Returns 0 on initial call, non-zero when returning via longjmp()
 *
 * jmp_buf layout (i386):
 *   [0] = PC (return address)
 *   [1] = EBX
 *   [2] = ESP
 *   [3] = EBP
 *   [4] = ESI
 *   [5] = EDI
 *   [6] = signal mask (from sigblock/sigsetmask)
 */
int
setjmp(jmp_buf env)
{
	int *jmpbuf = (int *)env;
	int mask;

	/* Save current signal mask */
	mask = sigblock(0);  /* sigblock(0) returns current mask without changing it */

	/* Save registers using inline assembly */
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

	/* Store signal mask at offset 24 (index 6) */
	jmpbuf[6] = mask;

	return 0;
}

/*
 * Restore context and signal mask from previous setjmp() call
 * Never returns to caller; execution continues at the setjmp() call site
 */
void
longjmp(jmp_buf env, int val)
{
	register int *jmpbuf __asm__("edx") = (int *)env;
	register int retval __asm__("eax") = val;
	int mask;

	/* Restore signal mask first */
	mask = jmpbuf[6];
	sigsetmask(mask);

	/* Ensure val is never 0 (longjmp always returns non-zero) */
	if (retval == 0)
		retval = 1;

	/* Restore registers and jump */
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
