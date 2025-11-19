#
# Makefile for the kernel's virtual memory subsystem. -wfj
# Updated for 4.4BSD-Lite2 VM
#

.PATH:	$S/kern/vm
KERN_SRCS+= \
	device_pager.c swap_pager.c vm_fault.c vm_glue.c vm_init.c \
	vm_kern.c vm_map.c vm_meter.c vm_mmap.c vm_object.c vm_page.c \
	vm_pageout.c vm_pager.c vm_swap.c vm_unix.c vm_user.c vnode_pager.c

SYMBOLS+= vm.symbols
MAN9+=	kmem.0 vmspace.0
MAN4+=	drum.0
