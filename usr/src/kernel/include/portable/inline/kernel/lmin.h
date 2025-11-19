/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_LMIN_H_
#define _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_LMIN_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: $
 * Long minimum function.
 */
__INLINE long
lmin(long l1, long l2)
{
	return (l1 < l2 ? l1 : l2);
}

#endif /* _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_LMIN_H_ */
