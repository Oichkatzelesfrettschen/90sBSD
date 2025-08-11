# ---------------------------------------------------------------------------
# Clang/LLD cross-compilation toolchain for 386BSD userland.
#
# This toolchain teaches CMake how to emit 32-bit i386 ELF objects using
# Clang and LLD.  The configuration is intentionally explicit so that
# developers are not surprised by implicit defaults drawn from the build
# host.  It assumes that an external script (see scripts/make-sysroot.sh)
# has produced a self-contained sysroot containing the 386BSD headers and
# a bootstrap libc.a archive.
# ---------------------------------------------------------------------------

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR i386)

set(TGT "i386-unknown-elf")

# Compilers ---------------------------------------------------------------
set(CMAKE_C_COMPILER clang)
set(CMAKE_C_COMPILER_TARGET "${TGT}")
set(CMAKE_ASM_COMPILER clang)
set(CMAKE_ASM_COMPILER_TARGET "${TGT}")
set(CMAKE_AR llvm-ar)
set(CMAKE_RANLIB llvm-ranlib)
set(CMAKE_LINKER ld.lld)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Sysroot handling -------------------------------------------------------
if(NOT DEFINED CMAKE_SYSROOT)
  if(DEFINED ENV{SYSROOT})
    set(CMAKE_SYSROOT "$ENV{SYSROOT}")
  else()
    message(FATAL_ERROR "CMAKE_SYSROOT or $SYSROOT must be set (e.g. sysroots/386bsd-elf)")
  endif()
endif()

# Compiler and linker flags ----------------------------------------------
set(COMMON_C_FLAGS "-ffreestanding -fno-builtin -fno-omit-frame-pointer -fno-stack-protector -fno-asynchronous-unwind-tables -m32 -march=i386 -mno-sse -mno-sse2 -mno-mmx -msoft-float -fuse-ld=lld --sysroot=${CMAKE_SYSROOT}")
set(CMAKE_C_FLAGS_INIT "${COMMON_C_FLAGS} -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers")
set(CMAKE_EXE_LINKER_FLAGS_INIT "-static --sysroot=${CMAKE_SYSROOT} -Wl,-m,elf_i386 -nostdlib")
set(CMAKE_TRY_COMPILE_CONFIGURATION Release)
