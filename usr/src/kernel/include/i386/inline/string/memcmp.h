/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_I386_INLINE_STRING_MEMCMP_H_
#define _KERNEL_INCLUDE_I386_INLINE_STRING_MEMCMP_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: memcmp.h,v 1.1 94/06/09 18:19:57 bill Exp Locker: bill $
 * POSIX block memory compare.
 */

__INLINE int
memcmp(const void *s1, const void *s2, size_t len) {
	extern const int zero;		/* compiler bug workaround */
	const void *s2p = s2 + zero;	/* compiler bug workaround */

	/* compare by words, then by bytes */
	asm volatile ("cld ; repe ; cmpsl ; jne 1f" :
	    "=D" (s1), "=S" (s2p) :
	    "0" (s1), "1" (s2p), "c" (len / 4));
	asm volatile ("repe ; cmpsb ; jne 1f" :
	    "=D" (s1), "=S" (s2p) :
	    "0" (s1), "1" (s2p), "c" (len & 3));

	return (0);	/* exact match */

	asm volatile ("1:");
	return (1);	/* failed match */
}

#endif /* _KERNEL_INCLUDE_I386_INLINE_STRING_MEMCMP_H_ */
