/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_KERN_I386_ASM_H_
#define _KERNEL_KERN_I386_ASM_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: asm.h,v 1.1 94/10/19 17:39:54 bill Exp $
 * Assembly macros.
 */

#define	ENTRY(name) \
	.globl _##name; .align 4;  _##name:
#define	ALTENTRY(name) \
	.globl _##name; _##name:


#endif /* _KERNEL_KERN_I386_ASM_H_ */
