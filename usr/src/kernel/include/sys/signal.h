#ifndef _SYS_SIGNAL_H_
#define _SYS_SIGNAL_H_

#include <sys/types.h>

/*
 * Signal numbers
 */
#define	SIGHUP	1	/* hangup */
#define	SIGINT	2	/* interrupt */
#define	SIGQUIT	3	/* quit */
#define	SIGILL	4	/* illegal instruction (not reset when caught) */
#define	SIGTRAP	5	/* trace trap (not reset when caught) */
#define	SIGABRT	6	/* abort() */
#define	SIGIOT	SIGABRT	/* compatibility */
#define	SIGEMT	7	/* EMT instruction */
#define	SIGFPE	8	/* floating point exception */
#define	SIGKILL	9	/* kill (cannot be caught or ignored) */
#define	SIGBUS	10	/* bus error */
#define	SIGSEGV	11	/* segmentation violation */
#define	SIGSYS	12	/* bad argument to system call */
#define	SIGPIPE	13	/* write on a pipe with no one to read it */
#define	SIGALRM	14	/* alarm clock */
#define	SIGTERM	15	/* software termination signal from kill */
#define	SIGURG	16	/* urgent condition on IO channel */
#define	SIGSTOP	17	/* sendable stop signal not from tty */
#define	SIGTSTP	18	/* stop signal from tty */
#define	SIGCONT	19	/* continue a stopped process */
#define	SIGCHLD	20	/* to parent on child stop or exit */
#define	SIGTTIN	21	/* to readers of a stopped tty */
#define	SIGTTOU	22	/* to writers of a stopped tty */
#define	SIGIO	23	/* input/output possible signal */
#define	SIGXCPU	24	/* exceeded CPU time limit */
#define	SIGXFSZ	25	/* exceeded file size limit */
#define	SIGVTALRM 26	/* virtual time alarm */
#define	SIGPROF	27	/* profiling time alarm */
#define	SIGWINCH 28	/* window size changes */
#define	SIGINFO	29	/* information request */
#define	SIGUSR1	30	/* user defined signal 1 */
#define	SIGUSR2	31	/* user defined signal 2 */

#define	NSIG	32

typedef unsigned int sigset_t;

/*
 * Signal vector "template" used in sigaction call.
 */
struct	sigaction {
	void	(*sa_handler)();	/* signal handler */
	sigset_t sa_mask;		/* signal mask to apply */
	int	sa_flags;		/* see signal options below */
};
#define SA_ONSTACK	0x0001	/* take signal on signal stack */
#define SA_RESTART	0x0002	/* restart system on signal return */
#define SA_NOCLDSTOP	0x0008	/* do not generate SIGCHLD on child stop */

/*
 * Flags for sigprocmask:
 */
#define	SIG_BLOCK	1	/* block specified signal set */
#define	SIG_UNBLOCK	2	/* unblock specified signal set */
#define	SIG_SETMASK	3	/* set specified signal set */

/*
 * For historical reasons; programs expect signal's return value to be
 * defined by <sys/signal.h>.
 */
#define	BADSIG		(void (*)())-1

#endif /* !_SYS_SIGNAL_H_ */