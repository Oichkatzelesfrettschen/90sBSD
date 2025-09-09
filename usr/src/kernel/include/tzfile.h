/*
 * Copyright (c) 1994 William F. Jolitz.
 * 386BSD Copyright Restrictions Apply. All Other Rights Reserved.
 *
 * tzfile.h - timezone file definitions for 386BSD kernel
 */

#ifndef _TZFILE_H_
#define _TZFILE_H_

/*
 * Information about time zone files.
 */

#define TZDIR	"/usr/share/zoneinfo" /* Time zone object file directory */
#define TZDEFAULT	"localtime"
#define TZDEFRULES	"posixrules"

/*
 * Each time zone file begins with a `struct tzhead'.
 */

#define TZ_MAGIC	"TZif"	/* TZ_* entries appear in this order */

struct tzhead {
	char	tzh_magic[4];		/* TZ_MAGIC */
	char	tzh_version[1];		/* '\0' or '2' as of 2013 */
	char	tzh_reserved[15];	/* reserved--must be zero */
	char	tzh_ttisgmtcnt[4];	/* coded number of trans. time flags */
	char	tzh_ttisstdcnt[4];	/* coded number of trans. time flags */
	char	tzh_leapcnt[4];		/* coded number of leap seconds */
	char	tzh_timecnt[4];		/* coded number of transition times */
	char	tzh_typecnt[4];		/* coded number of local time types */
	char	tzh_charcnt[4];		/* coded number of abbr. chars */
};

/*
 * . . .followed by. . .
 *
 * tzh_timecnt (char [4])s		coded transition times a la time(2)
 * tzh_timecnt (unsigned char)s	types of local time starting at above
 * tzh_typecnt repetitions of
 *	one (char [4])		coded UTC offset in seconds
 *	one (unsigned char)	used to set tm_isdst
 *	one (unsigned char)	that's an abbreviation list index
 * tzh_charcnt (char)s		'\0'-terminated zone abbreviation strings
 * tzh_leapcnt repetitions of
 *	one (char [4])		coded leap second transition times
 *	one (char [4])		total correction after above
 * tzh_ttisstdcnt (char)s	indexed by type; if TRUE, transition
 *				time is standard time, if FALSE,
 *				transition time is wall clock time
 *				if absent, transition times are
 *				assumed to be wall clock time
 * tzh_ttisgmtcnt (char)s	indexed by type; if TRUE, transition
 *				time is UTC, if FALSE,
 *				transition time is local time
 *				if absent, transition times are
 *				assumed to be local time
 */

/*
 * If tzh_version is '2' or greater, the above is followed by a second instance
 * of tzfile format, identical in structure except that
 * eight-byte time_t values are used instead of four-byte time_t values.
 * If tzh_version is '2', then the second instance also has a footer
 * consisting of a newline-enclosed POSIX TZ environment variable string.
 */

/*
 * In the current implementation, "tzset()" refuses to deal with files that
 * exceed any of the limits below.
 */

#ifndef TZ_MAX_TIMES
/*
 * The TZ_MAX_TIMES value below is enough to handle a bit more than a
 * year's worth of solar time (corrected daily to the nearest second) or
 * 138 years of Pacific Presidential Election time
 * (where there are three time zone transitions every fourth year).
 */
#define TZ_MAX_TIMES	370
#endif /* !defined TZ_MAX_TIMES */

#ifndef TZ_MAX_TYPES
#ifndef NOSOLAR
#define TZ_MAX_TYPES	256 /* Limited by what (unsigned char)'s can hold */
#else /* !NOSOLAR */
#define TZ_MAX_TYPES	10	/* Maximum number of local time types */
#endif /* !NOSOLAR */
#endif /* !defined TZ_MAX_TYPES */

#ifndef TZ_MAX_CHARS
#define TZ_MAX_CHARS	50	/* Maximum number of abbreviation characters */
				/* (limited by what unsigned chars can hold) */
#endif /* !defined TZ_MAX_CHARS */

#ifndef TZ_MAX_LEAPS
#define TZ_MAX_LEAPS	50	/* Maximum number of leap second corrections */
#endif /* !defined TZ_MAX_LEAPS */

#define SECSPERMIN	60
#define MINSPERHOUR	60
#define HOURSPERDAY	24
#define DAYSPERWEEK	7
#define DAYSPERNYEAR	365
#define DAYSPERLYEAR	366
#define SECSPERHOUR	(SECSPERMIN * MINSPERHOUR)
#define SECSPERDAY	((long) SECSPERHOUR * HOURSPERDAY)
#define MONSPERYEAR	12

#define TM_SUNDAY	0
#define TM_MONDAY	1
#define TM_TUESDAY	2
#define TM_WEDNESDAY	3
#define TM_THURSDAY	4
#define TM_FRIDAY	5
#define TM_SATURDAY	6

#define TM_JANUARY	0
#define TM_FEBRUARY	1
#define TM_MARCH	2
#define TM_APRIL	3
#define TM_MAY		4
#define TM_JUNE		5
#define TM_JULY		6
#define TM_AUGUST	7
#define TM_SEPTEMBER	8
#define TM_OCTOBER	9
#define TM_NOVEMBER	10
#define TM_DECEMBER	11

#define TM_YEAR_BASE	1900

#define EPOCH_YEAR	1970
#define EPOCH_WDAY	TM_THURSDAY

#define isleap(y) (((y) % 4) == 0 && (((y) % 100) != 0 || ((y) % 400) == 0))

/*
 * Since everything in isleap is modulo 400 (or a factor of 400), we know that
 *	isleap(y) == isleap(y % 400)
 * and so
 *	isleap(a + b) == isleap((a + b) % 400)
 * and so
 *	isleap(a + b) == isleap(a % 400 + b % 400)
 * This is true even if % means modulo rather than Fortran remainder
 * (which is allowed by C89 but not C99).
 * We use this to avoid addition overflow problems.
 */

#define isleap_sum(a, b)	isleap((a) % 400 + (b) % 400)

#endif /* _TZFILE_H_ */