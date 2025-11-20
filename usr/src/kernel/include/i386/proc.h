#ifndef _MACHINE_PROC_H_
#define _MACHINE_PROC_H_

/*
 * Machine-dependent proc structure.
 */
struct mdproc {
	int	*md_regs;	/* registers on current frame */
	void	*md_onfault;	/* fault handler */
	int	md_flags;	/* machine-dependent flags */
	int	md_tsel;	/* TSS selector */
};

/* md_flags */
#define	MDP_SSTEP	0x1	/* process is single stepping */
#define	MDP_SIGPROC	0x2	/* process is handling a signal */
#define	MDP_NPXCOLL	0x4	/* NPX context collided */
#define	MDP_AST		0x8	/* AST pending */
#define	MDP_RESCHED	0x10	/* RESCHED pending */

#endif /* !_MACHINE_PROC_H_ */