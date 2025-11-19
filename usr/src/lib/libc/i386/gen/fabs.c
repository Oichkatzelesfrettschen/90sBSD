/*-
 * Modern C implementation of fabs() - Floating point absolute value
 * Replaces legacy x87 assembly with compiler builtin
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)fabs.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <math.h>

/*
 * Floating point absolute value
 * Compiler generates optimal code (FABS instruction on x87, or simple bit clear on SSE)
 * Using builtin ensures maximum optimization and correct handling of NaN, infinity
 */
double
fabs(double x)
{
	return __builtin_fabs(x);
}
