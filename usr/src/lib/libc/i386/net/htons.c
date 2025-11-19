/*-
 * Modern C implementation of htons() - Host to Network Short (16-bit)
 * Replaces legacy assembly with compiler builtin for optimal performance
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)htons.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <sys/types.h>
#include <machine/endian.h>

/*
 * Convert 16-bit value from host byte order to network byte order (big-endian)
 * Generates optimal code (XCHG or ROL instruction on i386)
 */
u_short
htons(u_short x)
{
#if BYTE_ORDER == BIG_ENDIAN
	return x;
#elif BYTE_ORDER == LITTLE_ENDIAN
	return __builtin_bswap16(x);
#else
	return ((x & 0x00ffU) << 8) | ((x & 0xff00U) >> 8);
#endif
}
