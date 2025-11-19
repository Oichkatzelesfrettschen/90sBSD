/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_REMQUE_H_
#define _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_REMQUE_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: $
 * Function to remove an element from a queue.
 */
__INLINE void
_remque(queue_t element)
{
	(element->next)->prev = element->prev;
	(element->prev)->next = element->next;
	element->prev = (queue_t)0;
}

#endif /* _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_REMQUE_H_ */
