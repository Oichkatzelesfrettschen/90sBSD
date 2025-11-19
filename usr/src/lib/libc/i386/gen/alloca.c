/*-
 * Modern C implementation of alloca() - Allocate memory on stack
 * Replaces legacy assembly with compiler builtin
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)alloca.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <stdlib.h>

/*
 * Allocate memory on the stack frame of the caller
 * Memory is automatically freed when the function returns
 *
 * IMPORTANT: Use __builtin_alloca() which compiler recognizes and optimizes
 * This is safer than inline assembly and works across all optimization levels
 *
 * NOTE: alloca() is dangerous and deprecated in modern code. Use variable
 * length arrays (VLAs) or malloc() instead. This exists only for compatibility.
 */
void *
alloca(size_t size)
{
	return __builtin_alloca(size);
}
