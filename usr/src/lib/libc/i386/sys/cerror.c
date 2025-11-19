/*-
 * Modern C implementation of cerror() - Common error handler
 * Replaces legacy assembly with simple C function
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(SYSLIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)cerror.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* SYSLIBC_SCCS and not lint */

int errno;

/*
 * cerror() - common error return for syscall wrappers
 *
 * Sets errno from %eax and returns -1
 * This function is called by legacy assembly stubs
 */
int
cerror(int error_code)
{
	errno = error_code;
	return -1;
}
