/*-
 * Modern C implementation of ntohs() - Network to Host Short (16-bit)
 * Replaces legacy assembly with compiler builtin for optimal performance
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)ntohs.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <sys/types.h>
#include <machine/endian.h>

/*
 * Convert 16-bit value from network byte order (big-endian) to host byte order
 * Symmetric with htons() - same implementation
 */
u_short
ntohs(u_short x)
{
#if BYTE_ORDER == BIG_ENDIAN
	return x;
#elif BYTE_ORDER == LITTLE_ENDIAN
	return __builtin_bswap16(x);
#else
	return ((x & 0x00ffU) << 8) | ((x & 0xff00U) >> 8);
#endif
}
