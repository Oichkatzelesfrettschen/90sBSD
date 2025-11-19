/*-
 * Modern C implementation of ldexp() - Load exponent (x * 2^exp)
 * Replaces legacy x87 assembly with compiler builtin
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)ldexp.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <math.h>
#include <errno.h>

/*
 * Compute x * 2^exp efficiently
 * Compiler builtin generates optimal code (FSCALE on x87, or direct manipulation on SSE)
 * Handles overflow, underflow, and special values correctly
 */
double
ldexp(double x, int exp)
{
	return __builtin_ldexp(x, exp);
}
