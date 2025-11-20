/*
 * Copyright (c) 1995 The Regents of the University of California.
 * All rights reserved.
 *
 * This code contains ideas from software contributed to Berkeley by
 * Avadis Tevanian, Jr., Michael Wayne Young, and the Mach Operating
 * System project at Carnegie-Mellon University.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. All advertising materials mentioning features or use of this software
 *    must display the following acknowledgement:
 *	This product includes software developed by the University of
 *	California, Berkeley and its contributors.
 * 4. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
* LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *	@(#)lock.h	8.12 (Berkeley) 5/19/95
 */

#ifndef _SYS_LOCK_H_
#define _SYS_LOCK_H_

#include <machine/param.h>

/*
 * The lock structure is a single word of storage.
 *
 * All read operations are done using the lk_lock field, all
 * write operations are done using the lk_wlock field. These
 * overlap in memory. They can be tested to see if they are set
 * without interfering with other processors trying to set them.
 *
 * The lk_lock field is composed of three parts:
 *
 * LK_NSHARE_MASK	The number of shared locks currently held. When
 *			this is zero, an exclusive lock may be acquired.
 * LK_WANT_UPGRADE	The shared-lock holders are releasing their
 *			locks so that an exclusive lock may be acquired.
 * LK_WANT_EXCL		The lock is held shared, but an exclusive lock
 *			is wanted. The holder of the shared lock will
 *			release it and then try to acquire an exclusive
 *			lock.
 *
 * The lk_wlock field is composed of three parts:
 *
 * LK_HAVE_EXCL		The lock is held exclusive.
 * LK_WANT_EXCL		An exclusive lock is being requested.
 * LK_WANT_UPGRADE	A shared-to-exclusive upgrade is being requested.
 */
#define LK_NSHARE_MASK	0x000000ff
#define LK_WANT_UPGRADE	0x00000100	/* shared-to-exclusive upgrade */
#define LK_WANT_EXCL	0x00000200	/* exclusive request */
#define LK_HAVE_EXCL	0x00000400	/* exclusive lock */
#define LK_SHARE_NONZERO 0x00000800	/* lk_sharecount is non-zero */
#define LK_WAITDRAIN	0x00001000	/* waiting for lock to drain */
#define LK_DRAINING	0xdead0000	/* lock is being drained */
#define LK_DRAINED	0xbeef0000	/* lock has been drained */
#define LK_ALLINTS	(LK_WANT_UPGRADE|LK_WANT_EXCL|LK_HAVE_EXCL)

struct lock {
	/*
	 * This part of the structure is part of the lock promotion
	 * and backoff process. It should be aligned on a cache line
	 * boundary.
	 */
	struct simplelock lk_interlock;
	u_short	lk_flags;		/* see below */
	u_char	lk_prio;		/* priority at which to sleep */
	char	*lk_wmesg;		/* resource sleeping (for tsleep) */
	u_short lk_timo;		/* maximum sleep time (for tsleep) */
	u_short	lk_waitcount;		/* number of waiters */
	/*
	 * All exclusive locks are accounted for. The lk_lockholder field
	 * is the pid of the process that holds the lock.
	 */
	u_long	lk_exclusivecount;	/* count of recursive exclusive locks */
	pid_t	lk_lockholder;		/* pid of exclusive lock holder */
};

/*
 * Lock flags
 */
#define LK_TYPE_MASK	0x0000000f	/* type of lock */
#define LK_SHARED	0x00000001	/* shared lock */
#define LK_EXCLUSIVE	0x00000002	/* exclusive lock */
#define LK_UPGRADE	0x00000003	/* shared-to-exclusive upgrade */
#define LK_EXCLUPGRADE	0x00000004	/* exclusive upgrade */
#define LK_DOWNGRADE	0x00000005	/* exclusive-to-shared downgrade */
#define LK_RELEASE	0x00000006	/* release any type of lock */
#define LK_DRAIN	0x00000007	/* wait for all activity */
#define LK_REENABLE	0x00000008	/* reenable after draining */

#define LK_EXTFLG_MASK	0x0000fff0	/* mask of externally-set flags */
#define LK_NOWAIT	0x00000010	/* do not sleep to await lock */
#define LK_SLEEPFAIL	0x00000020	/* sleep, then return failure */
#define LK_CANRECURSE	0x00000040	/* allow recursive exclusive lock */
#define LK_NOPAUSE	0x00000080	/* do not pause for lock contention */
/*
 * Control flags
 */
#define LK_INTERLOCK	0x01000000	/* unlock passed simple lock */
#define LK_KERNPROC	-2		/* requires a negative pid */
#define LK_NOPROC	-1

#if defined(KERNEL) || defined(_KERNEL)
/*
 * Functions for manipulation of locks.
 */
void	lockinit __P((struct lock *lkp, int prio, char *wmesg, int timo,
		int flags));
int	lockmgr __P((volatile struct lock *lkp, u_int flags,
		struct simplelock *interlkp, struct proc *p));
int	lockstatus __P((struct lock *lkp));
void	lockmgr_printinfo __P((struct lock *lkp));
#endif

#endif /* !_SYS_LOCK_H_ */