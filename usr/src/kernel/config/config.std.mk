#
# Standard 386BSD kernel configuration.
#

# kernel
.include "$S/kern/Makefile.inc"

# residual 4.3BSD compatibility
.include "$S/kern/opt/compat43/Makefile.inc"

# standard socket IPC (BSD - UNIX communications domain)
# Using 4.4BSD-Lite2 uipc_usrreq.c from kern/ instead of 386BSD un/unusrreq.c
# .include "$S/un/Makefile.inc"

# standard pseudo devices
.include "$S/mem/Makefile.inc"
# Removed log and devtty - functionality already in kern (subr_log.c, tty_tty.c)
# .include "$S/log/Makefile.inc"
.include "$S/termios/Makefile.inc"
# .include "$S/devtty/Makefile.inc"

# standard filesystems
.include "$S/ufs/Makefile.inc"

.if ${MACHINE} == i386
#
# Standard PC/AT complement of devices
#

# standard bus
.include "$S/isa/Makefile.inc"

# standard devices
.include "$S/pccons/Makefile.inc"
.include "$S/aux/Makefile.inc"
.include "$S/wd/Makefile.inc"
.include "$S/fd/Makefile.inc"
.include "$S/com/Makefile.inc"
.include "$S/lpt/Makefile.inc"
.include "$S/npx/Makefile.inc"
.endif
