/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_IMIN_H_
#define _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_IMIN_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: $
 * Integer minimum function.
 */
__INLINE int
imin(int i1, int i2)
{
	return ((i1 < i2) ? i1 : i2);
}


#endif /* _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_IMIN_H_ */
