/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _LIB_LIBC_GEN_REGEXP_REGEXP_H_
#define _LIB_LIBC_GEN_REGEXP_REGEXP_H_

/*
 * Definitions etc. for regexp(3) routines.
 *
 * Caveat:  this is V8 regexp(3) [actually, a reimplementation thereof],
 * not the System V one.
 */
#define NSUBEXP  10
typedef struct regexp {
	char *startp[NSUBEXP];
	char *endp[NSUBEXP];
	char regstart;		/* Internal use only. */
	char reganch;		/* Internal use only. */
	char *regmust;		/* Internal use only. */
	int regmlen;		/* Internal use only. */
	char program[1];	/* Unwarranted chumminess with compiler. */
} regexp;

extern regexp *regcomp();
extern int regexec();
extern void regsub();
extern void regerror();

#endif /* _LIB_LIBC_GEN_REGEXP_REGEXP_H_ */
