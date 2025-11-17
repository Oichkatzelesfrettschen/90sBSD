#
# Makefile for the kernel of the kernel (kern) module. -wfj
#
# $Id: Makefile.inc,v 1.1 94/10/20 00:02:43 bill Exp $

.PATH:	$S/kern
KERN_SRCS+= \
	init_main.c init_sysent.c \
	kern_acct.c kern_clock.c kern_descrip.c kern_exec.c kern_exit.c \
	kern_fork.c kern_ktrace.c kern_lock.c kern_malloc.c kern_physio.c \
	kern_proc.c kern_prot.c kern_resource.c kern_sig.c kern_subr.c \
	kern_synch.c kern_sysctl.c kern_time.c kern_xxx.c \
	subr_autoconf.c subr_log.c subr_prf.c subr_prof.c subr_rmap.c subr_xxx.c \
	sys_generic.c sys_process.c sys_socket.c syscalls.c \
	tty.c tty_compat.c tty_conf.c tty_pty.c tty_subr.c tty_tb.c tty_tty.c \
	uipc_domain.c uipc_mbuf.c uipc_proto.c uipc_socket.c uipc_socket2.c \
	uipc_syscalls.c uipc_usrreq.c \
	vfs_bio.c vfs_cache.c vfs_cluster.c vfs_conf.c vfs_init.c \
	vfs_lookup.c vfs_subr.c vfs_syscalls.c vfs_vnops.c

SYMBOLS+= kern.symbols
MAN9+=	malloc.0 # kinfo.0 io.0 priv.0 process.0 config.0 lock.0
#	host.0 time.0 memory.0
MAN5+=	core.0
MAN4+=	fd.0 # ldisc.0 kern.0

# .include "$S/kern/fs/Makefile.inc"   # Using 4.4BSD-Lite2 vfs_*.c instead
.include "$S/kern/$(MACHINE)/Makefile.inc"
.include "$S/kern/net/Makefile.inc"
.include "$S/kern/socket/Makefile.inc"
.include "$S/kern/subr/Makefile.inc"
.include "$S/kern/vm/Makefile.inc"

# .include <bsd.kernel.mk>
