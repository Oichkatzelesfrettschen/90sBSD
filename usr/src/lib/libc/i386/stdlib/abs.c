/*-
 * Modern C implementation of abs() - Absolute value
 * Replaces legacy assembly with compiler builtin
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)abs.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <stdlib.h>

/*
 * Absolute value of an integer
 * Modern implementation using compiler builtin for optimal code generation
 */
int
abs(int j)
{
	return __builtin_abs(j);
}
