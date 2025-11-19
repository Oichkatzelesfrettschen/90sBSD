/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_IMAX_H_
#define _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_IMAX_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: $
 * Integer maximum function.
 */
__INLINE int
imax(int a, int b)
{
	return ((a > b) ? a : b);
}

#endif /* _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_IMAX_H_ */
