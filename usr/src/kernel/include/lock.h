#ifndef _LOCK_H_
#define _LOCK_H_

#include <sys/lock.h>
#include <sys/proc.h>

/*
 * This file is a compatibility layer for the old lock API.
 * It maps the old lock functions to the new lockmgr-based API.
 */

typedef struct lock lock_data_t;
typedef struct lock *lock_t;

static inline void
lock_init(lock_t l)
{
	lockinit(l, PVM, "lock", 0, 0);
}

static inline void
lock_write(lock_t l)
{
	lockmgr(l, LK_EXCLUSIVE, NULL, curproc);
}

static inline void
lock_done(lock_t l)
{
	lockmgr(l, LK_RELEASE, NULL, curproc);
}

static inline void
lock_read(lock_t l)
{
	lockmgr(l, LK_SHARED, NULL, curproc);
}

static inline int
lock_read_to_write(lock_t l)
{
	return lockmgr(l, LK_UPGRADE, NULL, curproc);
}

static inline void
lock_write_to_read(lock_t l)
{
	lockmgr(l, LK_DOWNGRADE, NULL, curproc);
}

static inline int
lock_try_write(lock_t l)
{
	return lockmgr(l, LK_EXCLUSIVE | LK_NOWAIT, NULL, curproc) == 0;
}

static inline int
lock_try_read(lock_t l)
{
	return lockmgr(l, LK_SHARED | LK_NOWAIT, NULL, curproc) == 0;
}

static inline int
lock_try_read_to_write(lock_t l)
{
	return lockmgr(l, LK_UPGRADE | LK_NOWAIT, NULL, curproc) == 0;
}

#define	lock_read_done(l)	lock_done(l)
#define	lock_write_done(l)	lock_done(l)

static inline void
lock_set_recursive(lock_t l)
{
	l->lk_flags |= LK_CANRECURSE;
}

static inline void
lock_clear_recursive(lock_t l)
{
	l->lk_flags &= ~LK_CANRECURSE;
}

#endif /* !_LOCK_H_ */