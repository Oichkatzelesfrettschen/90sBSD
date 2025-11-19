/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_MAX_H_
#define _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_MAX_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: $
 * Unsigned integer maximum function.
 */

__INLINE u_int
max(u_int u1, u_int u2)
{
	return (u1 > u2 ? u1 : u2);
}

#endif /* _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_MAX_H_ */
