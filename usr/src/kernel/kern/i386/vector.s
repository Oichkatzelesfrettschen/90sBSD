/*
 * Interrupt vector table and interrupt handler macros
 * Extracted from 386BSD locore.s for 4.4BSD-Lite2 compatibility
 */

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
	jmp	common_int_return

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
	movl	%ax, _cpl; \
	orw	_imen, %ax; \
	outb	%al, $IO_ICU1+1; \
	NOP ; \
	movb	%ah, %al; \
	outb	%al, $IO_ICU2+1; \
	WRPOST ; /* do write post */ \
	sti; \
	call	*(_isa_vec+offst*4); \
	jmp	common_int_return

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
