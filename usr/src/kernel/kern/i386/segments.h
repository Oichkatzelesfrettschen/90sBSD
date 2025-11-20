#ifndef _MACHINE_SEGMENTS_H_
#define _MACHINE_SEGMENTS_H_

/*
 * 386 Segmentation Data Structures and definitions
 *	William F. Jolitz (william@ernie.berkeley.edu) 6/20/1989
 */

typedef unsigned short sel_t;

/*
 * Selectors
 */

#define	ISPL(s)	((s)&3)		/* what is the priority level of a selector */
#define	SEL_KPL	0		/* kernel priority level */	
#define	SEL_UPL	3		/* user priority level */	
#define	ISLDT(s)	((s)&SEL_LDT)	/* is it local or global */
#define	SEL_LDT	4		/* local descriptor table */	
#define	IDXSEL(s)	(((s)>>3) & 0x1fff)		/* index of selector */
#define	LSEL(s,r)	(((s)<<3) | SEL_LDT | r)	/* a local selector */
#define	GSEL(s,r)	(((s)<<3) | r)			/* a global selector */

/*
 * Memory and System segment descriptors
 */
struct	segment_descriptor	{
	unsigned sd_lolimit:16 ;	/* segment extent (lsb) */
	unsigned sd_lobase:24 ;		/* segment base address (lsb) */
	unsigned sd_type:5 ;		/* segment type */
	unsigned sd_dpl:2 ;		/* segment descriptor priority level */
	unsigned sd_p:1 ;		/* segment descriptor present */
	unsigned sd_hilimit:4 ;		/* segment extent (msb) */
	unsigned sd_xx:2 ;		/* unused */
	unsigned sd_def32:1 ;		/* default 32 vs 16 bit size */
	unsigned sd_gran:1 ;		/* limit granularity (byte/page units)*/
	unsigned sd_hibase:8 ;		/* segment base address  (msb) */
} ;

/*
 * Gate descriptors (e.g. indirect descriptors)
 */
struct	gate_descriptor	{
	unsigned gd_looffset:16 ;	/* gate offset (lsb) */
	unsigned gd_selector:16 ;	/* gate segment selector */
	unsigned gd_stkcpy:5 ;		/* number of stack wds to cpy */
	unsigned gd_xx:3 ;		/* unused */
	unsigned gd_type:5 ;		/* segment type */
	unsigned gd_dpl:2 ;		/* segment descriptor priority level */
	unsigned gd_p:1 ;		/* segment descriptor present */
	unsigned gd_hioffset:16 ;	/* gate offset (msb) */
} ;

/*
 * Generic descriptor
 */
union	descriptor	{
	struct	segment_descriptor sd;
	struct	gate_descriptor gd;
};
#define	d_type	gd.gd_type

	/* system segments and gate types */
#define	SDT_SYSNULL	 0	/* system null */
#define	SDT_SYS286TSS	 1	/* system 286 TSS available */
#define	SDT_SYSLDT	 2	/* system local descriptor table */
#define	SDT_SYS286BSY	 3	/* system 286 TSS busy */
#define	SDT_SYS286CGT	 4	/* system 286 call gate */
#define	SDT_SYSTASKGT	 5	/* system task gate */
#define	SDT_SYS286IGT	 6	/* system 286 interrupt gate */
#define	SDT_SYS286TGT	 7	/* system 286 trap gate */
#define	SDT_SYSNULL2	 8	/* system null again */
#define	SDT_SYS386TSS	 9	/* system 386 TSS available */
#define	SDT_SYSNULL3	10	/* system null again */
#define	SDT_SYS386BSY	11	/* system 386 TSS busy */
#define	SDT_SYS386CGT	12	/* system 386 call gate */
#define	SDT_SYSNULL4	13	/* system null again */
#define	SDT_SYS386IGT	14	/* system 386 interrupt gate */
#define	SDT_SYS386TGT	15	/* system 386 trap gate */

	/* memory segment types */
#define	SDT_MEMRO	16	/* memory read only */
#define	SDT_MEMROA	17	/* memory read only accessed */
#define	SDT_MEMRW	18	/* memory read write */
#define	SDT_MEMRWA	19	/* memory read write accessed */
#define	SDT_MEMROD	20	/* memory read only expand dwn limit */
#define	SDT_MEMRODA	21	/* memory read only expand dwn limit accessed */
#define	SDT_MEMRWD	22	/* memory read write expand dwn limit */
#define	SDT_MEMRWDA	23	/* memory read write expand dwn limit acessed */
#define	SDT_MEME	24	/* memory execute only */
#define	SDT_MEMEA	25	/* memory execute only accessed */
#define	SDT_MEMER	26	/* memory execute read */
#define	SDT_MEMERA	27	/* memory execute read accessed */
#define	SDT_MEMEC	28	/* memory execute only conforming */
#define	SDT_MEMEAC	29	/* memory execute only accessed conforming */
#define	SDT_MEMERC	30	/* memory execute read conforming */
#define	SDT_MEMERAC	31	/* memory execute read accessed conforming */

/* is memory segment descriptor pointer ? */
#define ISMEMSDP(s)	((s->d_type) >= SDT_MEMRO && (s->d_type) <= SDT_MEMERAC)

/* is 286 gate descriptor pointer ? */
#define IS286GDP(s)	(((s->d_type) >= SDT_SYS286CGT \
				 && (s->d_type) < SDT_SYS286TGT))

/* is 386 gate descriptor pointer ? */
#define IS386GDP(s)	(((s->d_type) >= SDT_SYS386CGT \
				&& (s->d_type) < SDT_SYS386TGT))

/* is gate descriptor pointer ? */
#define ISGDP(s)	(IS286GDP(s) || IS386GDP(s))

/* is segment descriptor pointer ? */
#define ISSDP(s)	(ISMEMSDP(s) || !ISGDP(s))

/* is system segment descriptor pointer ? */
#define ISSYSSDP(s)	(!ISMEMSDP(s) && !ISGDP(s))

/*
 * Software definitions are in this convenient format,
 * which are translated into inconvenient segment descriptors
 * when needed to be used by the 386 hardware
 */

struct	soft_segment_descriptor	{
	unsigned ssd_base ;		/* segment base address  */
	unsigned ssd_limit ;		/* segment extent */
	unsigned ssd_type:5 ;		/* segment type */
	unsigned ssd_dpl:2 ;		/* segment descriptor priority level */
	unsigned ssd_p:1 ;		/* segment descriptor present */
	unsigned ssd_xx:4 ;		/* unused */
	unsigned ssd_xx1:2 ;		/* unused */
	unsigned ssd_def32:1 ;		/* default 32 vs 16 bit size */
	unsigned ssd_gran:1 ;		/* limit granularity (byte/page units)*/
};

/* Convert software segment descriptor to hardware format */
void ssdtosd(struct soft_segment_descriptor *ssdp, struct segment_descriptor *sdp);
/* Convert hardware segment descriptor to software format */
void sdtossd(struct segment_descriptor *sdp, struct soft_segment_descriptor *ssdp);

/*
 * region descriptors, used to load gdt/idt tables before segments yet exist
 */
struct region_descriptor {
	unsigned rd_limit:16 ;		/* segment extent */
	char *rd_base;			/* base address  */
};

/*
 * Segment Protection Exception code bits
 */

#define	SEGEX_EXT	0x01	/* recursive or externally induced */
#define	SEGEX_IDT	0x02	/* interrupt descriptor table */
#define	SEGEX_TI	0x04	/* local descriptor table */
				/* other bits are affected descriptor index */
#define SEGEX_IDX(s)	((s)>>3)&0x1fff)

/*
 * Size of IDT table
 */

#define	NIDT	256
#define	NRSVIDT	32		/* reserved entries for cpu exceptions */

/* special selectors in the kernel */
extern sel_t _udatasel, _ucodesel, _exit_tss_sel;

/* global descriptor table */
extern union descriptor *gdt, gdt_bootstrap[];

/* global descriptor table allocation pointers/counters */
extern struct segment_descriptor *sdfirstp_gdesc, *sdlast_gdesc,
    *sdlastfree_gdesc;
extern int sdngd_gdesc, sdnfree_gdesc;

void expanddesctable(void);

/*
 * Allocate a global descriptor to the kernel. If no free descriptors,
 * expand the table.
 */
static inline struct segment_descriptor *
allocdesc(void)
{
	struct segment_descriptor *sdp;
	int fullsearch = 1;

tryagain:
	/* out of global descriptors? then, make more */
	if (sdnfree_gdesc == 0)
		expanddesctable();

	/* find a free descriptor, starting with last freed descriptor */
	for (sdp = sdlastfree_gdesc; sdp <= sdlast_gdesc && sdp->sd_p ; sdp++)
		;

	/* if did not find a descriptor, start at beginning of table again */
	if (sdp > sdlast_gdesc && fullsearch) {
		sdlastfree_gdesc = sdfirstp_gdesc;
		fullsearch = 0;
		goto tryagain;
	}

#include <sys/systm.h>
#ifdef DIAGNOSTIC
	if(sdp->sd_p)
		panic("allocdesc: no free descriptor");
#endif

	/* next place to try? */
	if (sdp < sdlast_gdesc)
		sdlastfree_gdesc = sdp + 1;
	sdnfree_gdesc--;

	/* fill in the blanks */
	/* memset(sdp, 0, sizeof(*sdp));		/* XXX overkill */
	*(int *) sdp = 0; /* clear lower word */
	*(((int *) sdp) + 1) = 0; /* clear upper word */
	sdp->sd_p = 1;
	return (sdp);
}

/*
 * Return a Global descriptor to free status, so it may be reused.
 */
static inline void
freedesc(struct segment_descriptor *sdp)
{
	sdp->sd_p = 0;		/* will generate an invalid tss if used */
	sdnfree_gdesc++;
	if (sdlastfree_gdesc > sdp)
		sdlastfree_gdesc = sdp;
	/* XXX reduce table size if nfreedesc grows to larger than half of
	   total table side, and if we can compact the table. when we have
	   a surplus of descriptors, restrict allocation to first half, and
	   keep seperate counts on still allocated upper/lower halfs. We can
	   shrink the table by half when the outstanding allocated descriptors
	   in the top half drops to zero -- too hard for now. */
}


#ifdef _PROC_H_
/*
 * Allocate a TSS descriptor to a kernel thread, in the course of
 * creating a new thread. Special version of allocdesc().
 */
static inline
alloctss(struct proc *p) {
	struct segment_descriptor *sdp = allocdesc();
	sdp->sd_lolimit = sizeof(struct i386tss) - 1;
	sdp->sd_lobase = (int)p->p_addr;
	sdp->sd_hibase = ((int)p->p_addr) >> 24;
	sdp->sd_type = SDT_SYS386TSS;

	/* construct selector for new tss */
	p->p_md.md_tsel = GSEL((sdp - &gdt[0].sd), SEL_KPL);
}
#endif

/*
 * Return to the free pool the TSS descriptor of a thread being
 * deallocated. Special case of freedesc().
 */
static void ltr(sel_t sel);

static inline void
freetss(sel_t tss_sel) {

	/*
	 * if running on this thread, change to a interim
         * tss until we swtch()
	 */
	/* if (tss_sel == str()) */
		ltr(_exit_tss_sel); /* busy until final ljmp */

	freedesc(&gdt[IDXSEL(tss_sel)].sd);
}

inline void
ltr(sel_t sel)
{
	__asm__ volatile("ltr %0" : : "r" (sel));
}

#endif /* _KERNEL_KERN_I386_SEGMENTS_H_ */
