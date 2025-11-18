
__BEGIN_DECLS
void swtch(void);

/* interface symbols */
#define	__ISYM_VERSION__ "1"	/* XXX RCS major revision number of hdr file */
#include "isym.h"		/* this header has interface symbols */

/* functions used in modules */
__ISYM__(int, splx, (int))
__ISYM__(int, splimp, (void))
__ISYM__(int, splnet, (void))
__ISYM__(int, splhigh, (void))
__ISYM__(int, splclock, (void))

#undef __ISYM__
#undef __ISYM_ALIAS__
#undef __ISYM_VERSION__
/* u_char inb(u_short); */  /* now static inline */
u_char inb_(const u_char);	/* constant */
u_char __inb(u_short);		/* recovery time */
/* u_short inw(u_short); */  /* now static inline */
/* int inl(u_short); */  /* now static inline */
/* void insb (u_short, caddr_t, int); */  /* now static inline */
/* void insw (u_short, caddr_t, int); */  /* now static inline */
/* void insl (u_short, caddr_t, int); */  /* now static inline */
/* void outb(u_short, u_char); */  /* now static inline */
void outb_(const u_char, u_char);
void __outb(u_short, u_char);
/* void outw(u_short, u_short); */  /* now static inline */
/* void outl(u_short, int); */  /* now static inline */
/* void outsb (u_short, caddr_t, int); */  /* now static inline */
/* void outsw (u_short, caddr_t, int); */  /* now static inline */
/* void outsl (u_short, caddr_t, int); */  /* now static inline */

__END_DECLS
