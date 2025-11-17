/*
 * 386BSD Kernel Linker Script for i386
 * Based on traditional BSD kernel memory layout
 *
 * Kernel loads at physical address 0x100000 (1MB) - standard for i386
 * Virtual address 0xFE000000 (high memory mapping)
 */

OUTPUT_FORMAT("elf32-i386")
OUTPUT_ARCH(i386)
ENTRY(_start)

/* Kernel load address - physical 1MB, virtual high memory */
KERNEL_PHYS = 0x00100000;
KERNEL_VIRT = 0xFE000000;

SECTIONS
{
    /* Kernel starts at 1MB physical (for bootloader compatibility) */
    . = KERNEL_VIRT + KERNEL_PHYS;

    /* Read-only sections */
    .text ALIGN(4K) : AT(ADDR(.text) - KERNEL_VIRT)
    {
        *(.multiboot)  /* Multiboot header (if present) */
        *(.text)       /* Code */
        *(.text.*)
        *(.gnu.linkonce.t.*)
    }

    .rodata ALIGN(4K) : AT(ADDR(.rodata) - KERNEL_VIRT)
    {
        *(.rodata)     /* Read-only data */
        *(.rodata.*)
        *(.gnu.linkonce.r.*)
    }

    /* Read-write data sections */
    .data ALIGN(4K) : AT(ADDR(.data) - KERNEL_VIRT)
    {
        *(.data)       /* Initialized data */
        *(.data.*)
        *(.gnu.linkonce.d.*)
    }

    .bss ALIGN(4K) : AT(ADDR(.bss) - KERNEL_VIRT)
    {
        *(COMMON)      /* Common symbols */
        *(.bss)        /* Uninitialized data */
        *(.bss.*)
        *(.gnu.linkonce.b.*)
    }

    /* End of kernel marker */
    .end ALIGN(4K) : AT(ADDR(.end) - KERNEL_VIRT)
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
