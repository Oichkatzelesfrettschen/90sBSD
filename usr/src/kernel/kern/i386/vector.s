/*
 * Interrupt vector table and interrupt handler macros
 * Extracted from 386BSD locore.s for 4.4BSD-Lite2 compatibility
 */

/*
 * Assembly macros for x86-32 compatibility
 * Based on Agner Fog's optimization guidelines and legacy 386BSD code
 * Note: IDTVEC and ALIGN32 are defined in locore.s
 */

/*
 * NOP: I/O delay for old ISA bus timing
 * Modern systems don't need this, but kept for compatibility
 * Port 0x84 is the POST diagnostic port - reading it is a safe no-op
 */
#define	NOP	inb $0x84, %al ; inb $0x84, %al

/*
 * WRPOST: Write posting flush for ISA bus
 * Forces completion of any pending write operations
 * On modern systems with PCI/PCIe, this is unnecessary but harmless
 */
#define	WRPOST	inb $0x84, %al

/*
 * Interrupt vector interface.
 */

/* Mask a group of interrupts atomically */
#define	INTR1(offst) \
	pushl	$0; \
	pushl	$T_ASTFLT; \
	pushal; \
	NOP ; \
	movb	$(0x60|offst), %al; 	/* next, as soon as possible send EOI ... */ \
	outb	%al, $IO_ICU1; /* ... so in service bit may be cleared ...*/ \
	pushl	%ds; 		/* save our data and extra segments ... */ \
	pushl	%es; \
	movw	$0x10, %ax;	/* ... and reload with kernel's own */ \
	movw	%ax, %ds; \
	movw	%ax, %es; \
	incl	_cnt+V_INTR;	/* tally interrupts */ \
	incl	_intrcnt+offst*4; \
	movl	_cpl, %eax; \
	pushl	%eax; \
	pushl	_isa_unit+offst*4; \
	orw	_isa_mask+offst*2, %ax; \
	movl	%eax, _cpl; \
	orw	_imen, %ax; \
	NOP ; \
	outb	%al, $IO_ICU1+1; \
	movb	%ah, %al; \
	outb	%al, $IO_ICU2+1; \
	WRPOST ; /* do write post */ \
	sti; \
	call	*(_isa_vec+(offst*4)); \
	jmp	doreti			/* use doreti from icu.s for common return path */

/* Mask a group of interrupts atomically */
#define	INTR2(offst) \
	pushl	$0; \
	pushl	$T_ASTFLT; \
	pushal; \
	NOP ; \
	movb	$(0x60|(offst-8)), %al; 	/* next, as soon as possible send EOI ... */ \
	outb	%al, $IO_ICU2; \
	movb	$0x62, %al; 	/* next, as soon as possible send EOI ... */ \
	outb	%al, $IO_ICU1; /* ... so in service bit may be cleared ...*/ \
	pushl	%ds; 		/* save our data and extra segments ... */ \
	pushl	%es; \
	movw	$0x10, %ax;	/* ... and reload with kernel's own */ \
	movw	%ax, %ds; \
	movw	%ax, %es; \
	incl	_cnt+V_INTR;	/* tally interrupts */ \
	incl	_intrcnt+offst*4; \
	movl	_cpl,%eax; \
	pushl	%eax; \
	pushl	_isa_unit+offst*4; \
	orw	_isa_mask+offst*2, %ax; \
	movl	%eax, _cpl; \
	orw	_imen, %ax; \
	outb	%al, $IO_ICU1+1; \
	NOP ; \
	movb	%ah, %al; \
	outb	%al, $IO_ICU2+1; \
	WRPOST ; /* do write post */ \
	sti; \
	call	*(_isa_vec+offst*4); \
	jmp	doreti			/* use doreti from icu.s for common return path */

/*
 * Interrupt vector table:
 */
IDTVEC(irq0)	INTR1(0)
IDTVEC(irq1)	INTR1(1)
IDTVEC(irq2)	INTR1(2)
IDTVEC(irq3)	INTR1(3)
IDTVEC(irq4)	INTR1(4)
IDTVEC(irq5)	INTR1(5)
IDTVEC(irq6)	INTR1(6)
IDTVEC(irq7)	INTR1(7)
IDTVEC(irq8)	INTR2(8)
IDTVEC(irq9)	INTR2(9)
IDTVEC(irq10)	INTR2(10)
IDTVEC(irq11)	INTR2(11)
IDTVEC(irq12)	INTR2(12)
IDTVEC(irq13)	INTR2(13)
IDTVEC(irq14)	INTR2(14)
IDTVEC(irq15)	INTR2(15)

/* Default interrupt handler for unassigned interrupts */
IDTVEC(intrdefault)
	pushl	$0
	pushl	$T_ASTFLT
	pushal
	jmp	doreti

	.data
	.globl	_imen, _cpl
	.long 0
_cpl:	.long	IRHIGH - 2	/* current priority level (all off) */
_imen:	.word	0xffff - 2	/* interrupt mask enable (all off) */

netsirqsem: .word 0	/* network software interrupt request semaphore */

	.globl	_highmask
_highmask:	.long	IRHIGH - 2
	.globl	_ttymask
_ttymask:	.long	0
	.globl	_biomask
_biomask:	.long	0
	.globl	_netmask
_netmask:	.long	0

/* Aliases for Xirq naming convention (ISA compatibility) */
	.globl	Xirq0, Xirq1, Xirq2, Xirq3, Xirq4, Xirq5, Xirq6, Xirq7
	.globl	Xirq8, Xirq9, Xirq10, Xirq11, Xirq12, Xirq13, Xirq14, Xirq15
	.set	Xirq0, _Xirq0
	.set	Xirq1, _Xirq1
	.set	Xirq2, _Xirq2
	.set	Xirq3, _Xirq3
	.set	Xirq4, _Xirq4
	.set	Xirq5, _Xirq5
	.set	Xirq6, _Xirq6
	.set	Xirq7, _Xirq7
	.set	Xirq8, _Xirq8
	.set	Xirq9, _Xirq9
	.set	Xirq10, _Xirq10
	.set	Xirq11, _Xirq11
	.set	Xirq12, _Xirq12
	.set	Xirq13, _Xirq13
	.set	Xirq14, _Xirq14
	.set	Xirq15, _Xirq15

/* IRHIGH constant - all interrupts masked */
	.equ	IRHIGH, 0x3ffff

/* Additional aliases for Xintr naming (alternative interrupt naming) */
	.globl	Xintr0, Xintr1, Xintr2, Xintr3, Xintr4, Xintr5, Xintr6, Xintr7
	.globl	Xintr8, Xintr9, Xintr10, Xintr11, Xintr12, Xintr13, Xintr14, Xintr15
	.set	Xintr0, _Xirq0
	.set	Xintr1, _Xirq1
	.set	Xintr2, _Xirq2
	.set	Xintr3, _Xirq3
	.set	Xintr4, _Xirq4
	.set	Xintr5, _Xirq5
	.set	Xintr6, _Xirq6
	.set	Xintr7, _Xirq7
	.set	Xintr8, _Xirq8
	.set	Xintr9, _Xirq9
	.set	Xintr10, _Xirq10
	.set	Xintr11, _Xirq11
	.set	Xintr12, _Xirq12
	.set	Xintr13, _Xirq13
	.set	Xintr14, _Xirq14
	.set	Xintr15, _Xirq15

/* Default interrupt handler alias */
	.globl	Xintrdefault
	.set	Xintrdefault, _Xintrdefault

/* Export interrupt masks without underscore prefix */
	.globl	ttymask, biomask
	.set	ttymask, _ttymask
	.set	biomask, _biomask

/* SPL function aliases (from icu.s) */
	.globl	splhigh, splclock, spltty, splimp, splnet, splbio, splsoftclock, splnone, spl0, splx
	.set	splhigh, _splhigh
	.set	splclock, _splclock
	.set	spltty, _spltty
	.set	splimp, _splimp
	.set	splnet, _splnet
	.set	splbio, _splbio
	.set	splsoftclock, _splsoftclock
	.set	splnone, _splnone
	.set	spl0, _spl0
	.set	splx, _splx
