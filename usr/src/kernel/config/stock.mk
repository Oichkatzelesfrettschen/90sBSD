#
# Stock 386BSD operating system kernel configuration.
# Default configuration for generic hosts.
#

KERNEL=	386bsd
MACHINE= i386
IDENT=	-Di486

# standard kernel with minimal configuration
.include "$S/config/config.std.mk"		# standard configuration

# essential options for basic functionality  
.include "$S/kern/opt/ktrace/Makefile.inc"	# BSD ktrace mechanism
.include "$S/ddb/Makefile.inc"			# kernel debugger

.include "$S/config/kernel.mk"			# makefile boilerplate

# Force 32-bit compilation for legacy 386BSD on modern systems (must be after kernel.mk)
ASFLAGS= --32
CFLAGS+= -m32