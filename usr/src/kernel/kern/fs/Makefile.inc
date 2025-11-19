#
# Makefile for the filesystem subsystem of the kernel. -wfj
#
# $Id: Makefile.inc,v 1.1 94/10/19 17:09:13 bill Exp Locker: bill $

.PATH:	$S/kern/fs
KERN_SRCS+= \
	deadfs.c specfs.c
# bio.c, lookup.c, namcache.c, vfs.c, vnode.c provided by 4.4BSD-Lite2 vfs_* files
# fs_fops.c and fs_sys.c are legacy and not needed

# MAN9+=	fs.0 bio.0 vfs.0 vnode.0  namei.0
