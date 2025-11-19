/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _GAMES_HACK_DEF.GOLD_H_
#define _GAMES_HACK_DEF.GOLD_H_

/* Copyright (c) Stichting Mathematisch Centrum, Amsterdam, 1985. */
/* def.gold.h - version 1.0.2 */

struct gold {
	struct gold *ngold;
	xchar gx,gy;
	long amount;
};

extern struct gold *fgold;
struct gold *g_at();
#define newgold()	(struct gold *) alloc(sizeof(struct gold))

#endif /* _GAMES_HACK_DEF.GOLD_H_ */
