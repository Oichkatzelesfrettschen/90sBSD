cmake_minimum_required(VERSION 3.16)

# Static hello world stub for toolchain smoke testing. The
# toolchain file supplies the cross-compilation and linker flags.
add_executable(hello hello.c)

# Build a freestanding binary with no implicit runtime.
target_compile_options(hello PRIVATE -ffreestanding -fno-builtin)
target_link_options(hello PRIVATE -nostdlib -Wl,-e,_start)

# Produce an ELF binary with a distinctive suffix to avoid
# confusion with host executables.
set_target_properties(hello PROPERTIES OUTPUT_NAME "hello.elf")
