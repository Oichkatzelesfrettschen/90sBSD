/*
 * Multiboot Header Specification
 * Version 1.0 (compatible with GRUB Legacy and GRUB2)
 *
 * This header defines the Multiboot specification constants
 * for creating a bootable kernel image.
 */

#ifndef _MULTIBOOT_H_
#define _MULTIBOOT_H_

/* Multiboot header magic number */
#define MULTIBOOT_HEADER_MAGIC      0x1BADB002

/* Multiboot header flags */
#define MULTIBOOT_PAGE_ALIGN        0x00000001  /* Align modules on page boundaries */
#define MULTIBOOT_MEMORY_INFO       0x00000002  /* Provide memory map */
#define MULTIBOOT_VIDEO_MODE        0x00000004  /* Provide video mode info */

/* Standard flags for 386BSD kernel */
#define MULTIBOOT_HEADER_FLAGS      (MULTIBOOT_PAGE_ALIGN | MULTIBOOT_MEMORY_INFO)

/* Checksum: -(magic + flags) */
#define MULTIBOOT_HEADER_CHECKSUM   -(MULTIBOOT_HEADER_MAGIC + MULTIBOOT_HEADER_FLAGS)

/* Multiboot info structure magic */
#define MULTIBOOT_BOOTLOADER_MAGIC  0x2BADB002

#ifndef __ASSEMBLER__

/* Multiboot information structure passed by bootloader */
struct multiboot_info {
    unsigned long flags;
    unsigned long mem_lower;
    unsigned long mem_upper;
    unsigned long boot_device;
    unsigned long cmdline;
    unsigned long mods_count;
    unsigned long mods_addr;
    unsigned long syms[4];
    unsigned long mmap_length;
    unsigned long mmap_addr;
    unsigned long drives_length;
    unsigned long drives_addr;
    unsigned long config_table;
    unsigned long boot_loader_name;
    unsigned long apm_table;
    unsigned long vbe_control_info;
    unsigned long vbe_mode_info;
    unsigned short vbe_mode;
    unsigned short vbe_interface_seg;
    unsigned short vbe_interface_off;
    unsigned short vbe_interface_len;
};

/* Memory map entry */
struct multiboot_mmap_entry {
    unsigned long size;
    unsigned long long addr;
    unsigned long long len;
    unsigned long type;
} __attribute__((packed));

#endif /* !__ASSEMBLER__ */

#endif /* _MULTIBOOT_H_ */
