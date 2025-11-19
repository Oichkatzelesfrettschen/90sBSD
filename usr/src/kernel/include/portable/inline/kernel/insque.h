/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_INSQUE_H_
#define _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_INSQUE_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: $
 * Insert an element into a queue.
 */

__INLINE void
_insque(queue_t element, queue_t queue)
{
	element->next = queue->next;
	queue->next = element;
	element->prev = queue;
	element->next->prev = element;
}

#endif /* _KERNEL_INCLUDE_PORTABLE_INLINE_KERNEL_INSQUE_H_ */
