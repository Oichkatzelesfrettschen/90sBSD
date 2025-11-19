/*-
 * Modern C implementation of ntohl() - Network to Host Long (32-bit)
 * Replaces legacy assembly with compiler builtin for optimal performance
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)ntohl.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <sys/types.h>
#include <machine/endian.h>

/*
 * Convert 32-bit value from network byte order (big-endian) to host byte order
 * Symmetric with htonl() - same implementation
 */
u_long
ntohl(u_long x)
{
#if BYTE_ORDER == BIG_ENDIAN
	return x;
#elif BYTE_ORDER == LITTLE_ENDIAN
	return __builtin_bswap32(x);
#else
	return ((x & 0x000000ffUL) << 24) |
	       ((x & 0x0000ff00UL) <<  8) |
	       ((x & 0x00ff0000UL) >>  8) |
	       ((x & 0xff000000UL) >> 24);
#endif
}
