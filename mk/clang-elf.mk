# ---------------------------------------------------------------------------
# mk/clang-elf.mk
#
# BSD make profile that exposes a Clang/LLD based cross toolchain targeting
# 32-bit i386 System V ELF.  The variables exported here are intentionally
# minimalistic so legacy makefiles can opt-in without collateral changes.
#
# Usage:
#   make PROFILE=clang-elf <target>
# ---------------------------------------------------------------------------

SYSROOT?=$(CURDIR)/sysroots/386bsd-elf
export SYSROOT

export CC=clang
export AS=clang
export AR=llvm-ar
export RANLIB=llvm-ranlib
export LD=ld.lld

COMMON_CFLAGS= \
  -ffreestanding -fno-builtin -fno-omit-frame-pointer -fno-stack-protector \
  -fno-asynchronous-unwind-tables -m32 -march=i386 -mno-sse -mno-sse2 \
  -mno-mmx -msoft-float --sysroot=$(SYSROOT)
WARN_CFLAGS= \
  -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers
export CFLAGS?= -O2 $(COMMON_CFLAGS) $(WARN_CFLAGS)

export CPPFLAGS?= -nostdinc -isystem $(SYSROOT)/usr/include
export LDFLAGS?= -static --sysroot=$(SYSROOT) -m elf_i386 -nostdlib

export LIBC?=$(SYSROOT)/usr/lib/libc.a
