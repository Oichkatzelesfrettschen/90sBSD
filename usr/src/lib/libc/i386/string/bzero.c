/*-
 * Modern C implementation of bzero() - Zero a byte string
 * Replaces legacy assembly with compiler builtin
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)bzero.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <string.h>

/*
 * Zero out a memory region
 * Modern implementation using __builtin_memset for optimal code generation
 */
void
bzero(void *b, size_t length)
{
	__builtin_memset(b, 0, length);
}
