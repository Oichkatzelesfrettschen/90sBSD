#
# Makefile for the kernel's subroutine library. -wfj
# Updated for 4.4BSD-Lite2 hybrid build
#

.PATH:	$S/kern/subr
KERN_SRCS+= \
	disklabel.c disksort.c esym.c nullop.c subr_prf.c ring.c rlist.c uio.c \
	strcat.c strcpy.c strncpy.c strcmp.c

# Assembly machine-dependent subroutines handled by i386/Makefile.inc

ERROR=	ENXIO.o ENODEV.o EOPNOTSUPP.o ENOSYS.o ENOTTY.o

OBJS+=	${ERROR}

${ERROR}: $S/include/sys/errno.h
	@echo creating ${.PREFIX}.o
	@printf '#include "sys/errno.h"\n_${.PREFIX}_(){ return(${.PREFIX});}\n' \
	    > ${.PREFIX}.c
	@$(CC) -c ${.PREFIX}.c
	@rm ${.PREFIX}.c

SYMBOLS += subr.symbols
MAN9+=	esym.0 rlist.0
