/*
 * Include guard added by add-header-guards.sh
 * Date: 2025-11-19
 */
#ifndef _KERNEL_INCLUDE_DEV_ISA_KBD_H_
#define _KERNEL_INCLUDE_DEV_ISA_KBD_H_

/*
 * PC Keyboard definitions
 */

/* commands and responses */
#define	KBC_RESET	0xFF	/* Reset the keyboard */
#define	KBC_STSIND	0xED	/* set keyboard status indicators */
#define	KBR_OVERRUN	0x00	/* Keyboard flooded */
#define	KBR_RESEND	0xFE	/* Keyboard needs resend of command */
#define	KBR_ACK		0xFA	/* Keyboard did receive command */
#define	KBR_RSTDONE	0xAA	/* Keyboard reset complete */

#endif /* _KERNEL_INCLUDE_DEV_ISA_KBD_H_ */
