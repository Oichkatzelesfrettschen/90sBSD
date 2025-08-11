cmake_minimum_required(VERSION 3.16)

# Static hello world stub for toolchain smoke testing. The
# toolchain file supplies the cross-compilation and linker flags.
add_executable(hello hello.c)

# Produce an ELF binary with a distinctive suffix to avoid
# confusion with host executables.
set_target_properties(hello PROPERTIES OUTPUT_NAME "hello.elf")
