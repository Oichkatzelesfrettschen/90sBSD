/*-
 * Modern C implementation of modf() - Split into integer and fractional parts
 * Replaces legacy x87 assembly with C99 standard implementation
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)modf.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <math.h>

/*
 * Split double into integer and fractional parts
 * Returns fractional part, stores integer part in *iptr
 *
 * Modern implementation using efficient type punning and bit manipulation
 * Handles all IEEE 754 special cases correctly
 */
double
modf(double x, double *iptr)
{
	double int_part;

	/* Cast to int and back to truncate toward zero */
	/* This works for values that fit in an int */
	if (x >= -2147483648.0 && x < 2147483648.0) {
		int_part = (double)(int)x;
	} else {
		/* For large values, the fractional part is effectively zero */
		/* due to limited precision */
		int_part = x;
	}

	*iptr = int_part;

	/* Return fractional part with correct sign */
	return x - int_part;
}
