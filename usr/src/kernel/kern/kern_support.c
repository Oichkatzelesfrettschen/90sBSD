/*
 * Kernel support functions and stubs for 386BSD
 * Provides missing standard library and kernel support routines
 */

#include <sys/param.h>
#include <sys/systm.h>
#include <sys/buf.h>
#include <sys/vnode.h>

/* Standard C library functions not provided by compiler */

int
memcmp(const void *s1, const void *s2, size_t n)
{
	const unsigned char *p1 = s1, *p2 = s2;

	while (n-- > 0) {
		if (*p1 != *p2)
			return (*p1 - *p2);
		p1++;
		p2++;
	}
	return 0;
}

size_t
strlen(const char *s)
{
	const char *p = s;

	while (*p)
		p++;
	return (p - s);
}

/* VFS buffer support functions */

/*
 * vflushbuf - Flush buffers for a vnode
 * Stub implementation - real version would flush dirty buffers
 */
void
vflushbuf(struct vnode *vp)
{
	/* Stub - would flush vnode buffers in real implementation */
	return;
}

/*
 * breada - Block read-ahead
 * Stub implementation - real version would read ahead
 */
int
breada(struct vnode *vp, daddr_t blkno, int size, daddr_t rablkno, int rabsize,
       struct ucred *cred, struct buf **bpp)
{
	/* Stub - just call bread without read-ahead */
	return bread(vp, blkno, size, cred, bpp);
}

/* Global buffer pool - minimal stub */
static struct buf _buf_storage[1];  /* Single buffer for stub purposes */
struct buf *buf = _buf_storage;  /* Matches header declaration */

/* Privilege checking stub */
int use_priv = 0;  /* Privilege checking disabled for now */

/* Kernel globals */
int hz = 100;  /* System clock frequency - 100Hz */

/* Line discipline interface stubs */
int
ldiscif_open(struct tty *tp)
{
	return 0;
}

int
ldiscif_close(struct tty *tp)
{
	return 0;
}

int
ldiscif_ioctl(struct tty *tp, int cmd, caddr_t data, int flag)
{
	return ENOTTY;  /* Not supported */
}

/* DELAY - microsecond delay (stub) */
void
DELAY(int n)
{
	/* Stub - would do busy wait delay in real implementation */
	volatile int i;
	for (i = 0; i < n * 10; i++)
		;
}

/* Additional line discipline interface stubs */
int
ldiscif_read(struct tty *tp, struct uio *uio, int flag)
{
	return 0;
}

int
ldiscif_write(struct tty *tp, struct uio *uio, int flag)
{
	return 0;
}

void
ldiscif_rint(int c, struct tty *tp)
{
	/* Stub */
}

int
ldiscif_modem(struct tty *tp, int flag)
{
	return 0;
}

void
ldiscif_start(struct tty *tp)
{
	/* Stub */
}

/* Ring buffer initialization stub for aux device */
void
initrb(void *rb)
{
	/* Stub */
}

/* Final batch of kernel support stubs */

/* IRQ management */
void setirq(int irq) { /* Stub */ }

/* I/O port operations - inline stubs */
void __outb(unsigned short port, unsigned char val) { asm volatile("outb %0, %1" : : "a"(val), "Nd"(port)); }

/* Pmap kernel */
void *pmap_kernel(void) { static int dummy; return &dummy; }

/* Global interrupt variables */
unsigned short imen = 0xffff;  /* Interrupt mask */
long netmask = 0;  /* Network interrupt mask */
char intrnames[256];  /* Interrupt names */

/* Module scanning */
void modscaninit(void) { /* Stub */ }

/* CPU reset */
void cpu_reset(void) { while(1); }

/* Memory move - will use assembly version */
extern void *memmove(void *, const void *, size_t);

/* Console character input */
int console_getchar(void) { return -1; }

/* Find first set bit */
int ffs(int value) {
	int bit = 1;
	if (!value) return 0;
	while (!(value & 1)) { value >>= 1; bit++; }
	return bit;
}

/* Signal to process ID */
void signalpid(int pid, int sig) { /* Stub */ }

/* VM related */
extern char vmmap[4096];  /* Forward declare for linker */
extern int kernspace;  /* Kernel space descriptor */
int vmspace_access(void *vs, caddr_t addr, int len, int prot) { return 1; }

/* Configuration */
char *cfg_char(void *cfg, char *name) { return ""; }
int cfg_number(void *cfg, char *name) { return 0; }

/* AT device base */
caddr_t atdevbase = (caddr_t)0;
/* Final kernel stubs - vmmap and kernspace */
#include <sys/param.h>

/* VM map for mem device */
char vmmap[NBPG];

/* Kernel space descriptor stub */
int kernspace = 0;

/* memmove wrapper */
extern void *_memmove(void *dst, const void *src, size_t len);
void *memmove(void *dst, const void *src, size_t len) {
	return _memmove(dst, src, len);
}

/* VM physical map */
void *phys_map = NULL;

/* Current process */
struct proc *curproc = NULL;
void *_curproc = NULL;  /* Assembly expects underscore version */

/* Final undefined symbols */

/* VM meter statistics */
#include <sys/vmmeter.h>
struct vmmeter cnt = {0};

/* NPX (FPU) process ownership */
struct proc *npxproc = NULL;

/* VM maps */
void *kernel_map = NULL;

/* Page table map */
void *PTmap = NULL;  /* Page table map stub */


/* Additional kernel functions */

/* Process scheduling */
void setrunqueue(struct proc *p) { /* Stub */ }

/* User profiling - use assembly version if working, else stub */
extern void _addupc(int pc, struct uprof *up, int ticks);
void addupc(int pc, struct uprof *up, int ticks) {
	/* Stub - profiling disabled */
}

/* Memory copy - bcopy */
extern void *memmove(void *, const void *, size_t);
void bcopy(const void *src, void *dst, size_t len) {
	memmove(dst, src, len);
}

/* Move ESP - stub */
int mvesp(void) { return 0; }


/* Low-level kernel globals and functions */

/* Physical-to-virtual table */
void *pv_table = NULL;

/* Page table directory */
void *PTD = NULL;

/* System state */
int cold = 1;  /* System is still cold-starting */
int cpl = 0;  /* Current priority level */

/* Fetch word from user space */
int fuword(void *addr) { return -1; /* Stub */ }

/* Read CR2 register (page fault address) */
unsigned long rcr2(void) { return 0; }

/* AST off function */
void astoff(void) { /* Stub */ }

/* NPX DNA (Device Not Available) handler */
void npxdna(void) { /* Stub */ }


/* Pmap-related globals */
void *PTDpde = NULL;
void *APTDpde = NULL;
void *APTmap = NULL;
void *IdlePTD = NULL;

/* Memory operations */
void bzero(void *s, size_t n) {
	char *p = s;
	while (n--) *p++ = 0;
}

void blkclr(void *s, size_t n) {
	bzero(s, n);
}

/* Load CR3 register */
void load_cr3(unsigned long val) {
	asm volatile("movl %0, %%cr3" : : "r"(val));
}


/* Boot-time globals */
extern int boothowto;  /* Already declared elsewhere */
int bootdev = 0;  /* Boot device */
void *curpcb = NULL;  /* Current PCB */

/* init386 - i386 initialization */
void init386(void) { /* Stub */ }

/* Segment selectors */
int _ucodesel = 0x08;  /* User code selector */
int _udatasel = 0x10;  /* User data selector */

/* Console display memory */
void *Crtat = (void *)0xb8000;  /* CRT attribute/character */
void *_Crtat = (void *)0xb8000;

