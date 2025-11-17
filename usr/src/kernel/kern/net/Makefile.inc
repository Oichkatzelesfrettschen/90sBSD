#
# Makefile for the networking subsystem. -wfj  
# Updated for 4.4BSD-Lite2 net files
#

.PATH:	$S/kern/net
KERN_SRCS+= \
	bpf.c bpf_filter.c if.c if_ethersubr.c if_loop.c \
	if_sl.c radix.c raw_cb.c raw_usrreq.c \
	route.c rtsock.c slcompress.c

SYMBOLS+= net.symbols
MAN4+=	netintro.0
