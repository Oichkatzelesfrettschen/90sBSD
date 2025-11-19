/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_KERN_I386_SIGFRAME_H_
#define _KERNEL_KERN_I386_SIGFRAME_H_

/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * $Id: sigframe.h,v 1.1 94/10/19 17:40:08 bill Exp $
 * Assembly macros.
 */

struct sigframe {
	int	sf_signum;
	int	sf_code;
	struct	sigcontext *sf_scp;
	sig_t	sf_handler;
	int	sf_eax;	
	int	sf_edx;	
	int	sf_ecx;	
	char	sf_sigcode[16];
	struct	sigcontext sf_sc;
} ;

#endif /* _KERNEL_KERN_I386_SIGFRAME_H_ */
