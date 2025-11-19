/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _GAMES_HACK_DEF.FUNC_TAB_H_
#define _GAMES_HACK_DEF.FUNC_TAB_H_

/* Copyright (c) Stichting Mathematisch Centrum, Amsterdam, 1985. */
/* def.func_tab.h - version 1.0.2 */

struct func_tab {
	char f_char;
	int (*f_funct)();
};

extern struct func_tab cmdlist[];

struct ext_func_tab {
	char *ef_txt;
	int (*ef_funct)();
};

extern struct ext_func_tab extcmdlist[];

#endif /* _GAMES_HACK_DEF.FUNC_TAB_H_ */
