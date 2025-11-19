/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_I386_INLINE_STRING_MEMCPY_H_
#define _KERNEL_INCLUDE_I386_INLINE_STRING_MEMCPY_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: memcpy.h,v 1.1 94/06/09 18:19:59 bill Exp Locker: bill $
 * POSIX (non-overlapping) block memory copy.
 */

__INLINE void *
memcpy(void *to, const void *from, size_t len) {
	void *rv = to;
	extern const int zero;		/* compiler bug workaround */
	const void *f = from + zero;	/* compiler bug workaround */

	asm volatile ("cld ; repe ; movsl" :
	    "=D" (to), "=S" (f) :
	    "0" (to), "1" (f), "c" (len / 4));

	asm volatile ("repe ; movsb" :
	    "=D" (to), "=S" (f) :
	    "0" (to), "1" (f), "c" (len & 3));

	return (rv);
}

#endif /* _KERNEL_INCLUDE_I386_INLINE_STRING_MEMCPY_H_ */
