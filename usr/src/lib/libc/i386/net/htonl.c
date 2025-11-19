/*-
 * Modern C implementation of htonl() - Host to Network Long (32-bit)
 * Replaces legacy assembly with compiler builtin for optimal performance
 *
 * Copyright (c) 1990 The Regents of the University of California.
 * Modernized for C99+ compilers
 */

#if defined(LIBC_SCCS) && !defined(lint)
static char sccsid[] = "@(#)htonl.c	5.2 (Berkeley Modernized) 11/19/25";
#endif /* LIBC_SCCS and not lint */

#include <sys/types.h>
#include <machine/endian.h>

/*
 * Convert 32-bit value from host byte order to network byte order (big-endian)
 * On little-endian i386: swap bytes
 * On big-endian: no-op
 *
 * Modern compiler builtins generate optimal code (single BSWAP instruction on i386)
 */
u_long
htonl(u_long x)
{
#if BYTE_ORDER == BIG_ENDIAN
	/* Big-endian: network order == host order, no conversion needed */
	return x;
#elif BYTE_ORDER == LITTLE_ENDIAN
	/* Little-endian: use compiler builtin for optimal byte swap */
	return __builtin_bswap32(x);
#else
	/* Fallback portable implementation (compilers optimize this well) */
	return ((x & 0x000000ffUL) << 24) |
	       ((x & 0x0000ff00UL) <<  8) |
	       ((x & 0x00ff0000UL) >>  8) |
	       ((x & 0xff000000UL) >> 24);
#endif
}
