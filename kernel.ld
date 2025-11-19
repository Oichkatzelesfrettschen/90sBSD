/*
 * 386BSD Kernel Linker Script for i386 (Multiboot-compliant)
 * Based on traditional BSD kernel memory layout
 *
 * Kernel loads at physical address 0x100000 (1MB) - standard for Multiboot
 * Using flat memory model for Phase 6/7 boot testing
 */

OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

/* Kernel load address - 1MB physical (Multiboot standard) */
KERNEL_BASE = 0x00100000;

SECTIONS
{
    /* Kernel starts at 1MB physical (for Multiboot bootloader) */
    . = KERNEL_BASE;

    /* Multiboot header MUST be in first 8KB */
    .multiboot ALIGN(4) :
    {
        *(.multiboot)  /* Multiboot header from boot.S */
    }

    /* Code section */
    .text ALIGN(4K) :
    {
        *(.text)       /* Code */
        *(.text.*)
        *(.gnu.linkonce.t.*)
    }

    /* Read-only data */
    .rodata ALIGN(4K) :
    {
        *(.rodata)     /* Read-only data */
        *(.rodata.*)
        *(.gnu.linkonce.r.*)
    }

    /* Read-write data sections */
    .data ALIGN(4K) :
    {
        *(.data)       /* Initialized data */
        *(.data.*)
        *(.gnu.linkonce.d.*)
    }

    /* BSS (uninitialized data) */
    .bss ALIGN(4K) :
    {
        *(COMMON)      /* Common symbols */
        *(.bss)        /* Uninitialized data */
        *(.bss.*)
        *(.gnu.linkonce.b.*)
    }

    /* End of kernel marker */
    .end ALIGN(4K) :
    {
        end = .;
        _end = .;
        __end = .;
    }

    /* Discard unnecessary sections */
    /DISCARD/ :
    {
        *(.comment)
        *(.note)
        *(.note.*)
        *(.eh_frame)
        *(.eh_frame_hdr)
    }
}
