/*
 * Vnode operation descriptor stubs for 386BSD
 * These provide minimal definitions for vnode ops expected by vfs_conf.c
 */

#include <sys/param.h>
#include <sys/vnode.h>

/*
 * Stub vnode operation vectors
 * These are minimal definitions - real implementations would be in UFS/FFS code
 */

/* FFS (Fast File System) vnode operations */
int (**ffs_vnodeop_p)();
struct vnodeopv_desc ffs_vnodeop_opv_desc = {
	&ffs_vnodeop_p, NULL
};

/* FFS special device operations */
int (**ffs_specop_p)();
struct vnodeopv_desc ffs_specop_opv_desc = {
	&ffs_specop_p, NULL
};

/* Dead vnode operations (from deadfs.c) */
int (**dead_vnodeop_p)();
struct vnodeopv_desc dead_vnodeop_opv_desc = {
	&dead_vnodeop_p, NULL
};

/* Special device operations (from specfs.c) */
int (**spec_vnodeop_p)();
struct vnodeopv_desc spec_vnodeop_opv_desc = {
	&spec_vnodeop_p, NULL
};
