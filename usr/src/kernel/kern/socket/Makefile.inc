#
# Makefile for the socket subsystem of the kernel. -wfj
# NOTE: 4.4BSD-Lite2 uses uipc_*.c files in kern/ instead of socket/ subdirectory
# This Makefile is disabled - socket code is in kern/Makefile.inc
#

.PATH:	$S/kern/socket

# All socket functionality is in uipc_*.c files (already in KERN_SRCS)
# No additional files needed here

SYMBOLS+= socket.symbols
