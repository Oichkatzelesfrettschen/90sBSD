/*
 * 386BSD Kernel Boot Stub
 * Multiboot-compliant entry point for GRUB/GRUB2
 *
 * This file provides the multiboot header and initial entry point
 * for the 386BSD kernel when loaded by a Multiboot-compliant bootloader.
 */

#define __ASSEMBLER__
#include "../include/multiboot.h"

.section .multiboot
.align 4

/* Multiboot header */
multiboot_header:
    .long MULTIBOOT_HEADER_MAGIC
    .long MULTIBOOT_HEADER_FLAGS
    .long MULTIBOOT_HEADER_CHECKSUM

.section .bss
.align 16

/* Kernel stack (16KB) */
stack_bottom:
    .skip 16384  /* 16KB stack */
stack_top:

.section .text
.global _start
.type _start, @function

_start:
    /* Disable interrupts */
    cli

    /* Set up stack */
    movl $stack_top, %esp
    movl $stack_top, %ebp

    /* Reset EFLAGS */
    pushl $0
    popf

    /*
     * At this point, we have:
     * EAX = Multiboot magic (0x2BADB002)
     * EBX = Address of Multiboot information structure
     *
     * Save these for the kernel
     */
    pushl %ebx  /* Multiboot info pointer */
    pushl %eax  /* Multiboot magic */

    /* Call kernel main function */
    call kernel_main

    /* If kernel_main returns (it shouldn't), hang */
halt_loop:
    cli
    hlt
    jmp halt_loop

/* Set the size of the _start symbol */
.size _start, . - _start
