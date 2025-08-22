cmake_minimum_required(VERSION 3.16)

# Top-level CMake entry point for 386BSD. Historically this project
# only drove documentation via CMake, but optional test targets are
# provided to validate cross-compilation infrastructure.
project(386BSD C)

option(BUILD_DOCS "Build documentation with Doxygen and Sphinx" ON)
option(BUILD_TESTS "Build auxiliary test binaries" ON)
option(EXPORT_COMPILE_COMMANDS "Export compile_commands.json" ON)

if(EXPORT_COMPILE_COMMANDS)
  set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
endif()

find_package(Python3 COMPONENTS Interpreter)

if(BUILD_DOCS)
  add_subdirectory(docs)
endif()

if(BUILD_TESTS)
  add_subdirectory(tests)
endif()

if(Python3_Interpreter_FOUND)
  add_custom_target(
    include-audit
    COMMAND ${Python3_EXECUTABLE} ${CMAKE_SOURCE_DIR}/scripts/scan-includes.py
            ${CMAKE_SOURCE_DIR}/usr/src
            -I ${CMAKE_SOURCE_DIR}/usr/include
            -I ${CMAKE_SOURCE_DIR}/usr/src/include
            -I ${CMAKE_SOURCE_DIR}/usr/src/lib/libc/include
            --compile-commands ${CMAKE_BINARY_DIR}/compile_commands.json
            --missing-only
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    COMMENT "Audit header includes"
  )
endif()
