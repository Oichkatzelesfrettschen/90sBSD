/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * nlist.h - symbol table interface for 386BSD kernel
 */

#ifndef _NLIST_H_
#define _NLIST_H_

/*
 * Format of a symbol table entry; this file gives the layout of the symbol
 * table entries for all programs running under 386BSD. The a.out.h file
 * must be included before this file.
 */

struct nlist {
	union {
		char *n_name;	/* symbol name */
		struct nlist *n_next;	/* for use internally to ld */
		long n_strx;		/* index into file string table */
	} n_un;
	unsigned char n_type;	/* type flag, see below */
	char n_other;		/* unused */
	short n_desc;		/* see <stab.h> */
	unsigned long n_value;	/* value of this symbol (or sdb offset) */
};

/*
 * Simple values for n_type.
 */
#define N_UNDF	0x0		/* undefined */
#define N_ABS	0x2		/* absolute */
#define N_TEXT	0x4		/* text */
#define N_DATA	0x6		/* data */
#define N_BSS	0x8		/* bss */
#define N_COMM	0x12		/* common (internal to ld) */
#define N_FN	0x1f		/* file name symbol */

#define N_EXT	01		/* external bit, or'ed in */
#define N_TYPE	0x1e		/* mask for all the type bits */

/*
 * Sdb entries have some of the N_STAB bits set.
 * These are given in <stab.h>
 */
#define N_STAB	0xe0		/* if any of these bits set, a SDB entry */

/*
 * Format for namelist values.
 */
#define N_FORMAT	"%08x"

/*
 * External function prototypes
 */
#ifdef __cplusplus
extern "C" {
#endif

int nlist(const char *, struct nlist *);

#ifdef __cplusplus
}
#endif

#endif /* _NLIST_H_ */