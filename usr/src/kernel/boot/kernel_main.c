/*
 * 386BSD Kernel Main Entry Point
 * Called by boot.S after multiboot initialization
 *
 * This is the C entry point for the 386BSD kernel.
 * For now, this is a minimal stub that just writes to VGA text mode
 * and halts. Future work will initialize the full kernel.
 */

#include "multiboot.h"

/* VGA text mode buffer */
#define VGA_BUFFER ((unsigned short*)0xB8000)
#define VGA_WIDTH 80
#define VGA_HEIGHT 25

/* VGA color codes */
#define VGA_COLOR_BLACK 0
#define VGA_COLOR_WHITE 15

/* Create VGA entry with character and color */
static inline unsigned short vga_entry(unsigned char ch, unsigned char color) {
    return (unsigned short)ch | (unsigned short)color << 8;
}

/* Simple string output to VGA */
static void vga_puts(const char *str, int row, int col, unsigned char color) {
    unsigned short *vga = VGA_BUFFER + (row * VGA_WIDTH + col);
    while (*str) {
        *vga++ = vga_entry(*str++, color);
    }
}

/* Clear VGA screen */
static void vga_clear(void) {
    unsigned short *vga = VGA_BUFFER;
    unsigned short blank = vga_entry(' ', VGA_COLOR_BLACK | (VGA_COLOR_BLACK << 4));

    for (int i = 0; i < VGA_WIDTH * VGA_HEIGHT; i++) {
        vga[i] = blank;
    }
}

/*
 * Kernel main function
 * Called by boot.S with multiboot information
 *
 * Parameters:
 *   magic - Multiboot magic number (should be 0x2BADB002)
 *   mbi   - Pointer to multiboot information structure
 */
void kernel_main(unsigned long magic, struct multiboot_info *mbi) {
    /* Clear screen */
    vga_clear();

    /* Display boot message */
    vga_puts("386BSD Kernel Starting...", 0, 0, VGA_COLOR_WHITE | (VGA_COLOR_BLACK << 4));

    /* Verify multiboot magic */
    if (magic != MULTIBOOT_BOOTLOADER_MAGIC) {
        vga_puts("ERROR: Invalid multiboot magic!", 2, 0, 0x04);  /* Red on black */
        goto halt;
    }

    vga_puts("Multiboot magic: OK", 2, 0, 0x0A);  /* Green on black */

    /* Display memory information if available */
    if (mbi->flags & 0x01) {
        vga_puts("Memory info available", 3, 0, 0x0A);
    }

    /* Boot successful message */
    vga_puts("386BSD kernel loaded successfully!", 5, 0, 0x0E);  /* Yellow on black */
    vga_puts("System halted. (This is expected for Phase 6/7 test)", 7, 0, 0x07);

halt:
    /* Halt the CPU - kernel has "booted" successfully */
    while (1) {
        __asm__ volatile ("hlt");
    }
}
