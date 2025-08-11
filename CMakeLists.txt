cmake_minimum_required(VERSION 3.16)

# Top-level CMake entry point for 386BSD. Historically this project
# only drove documentation via CMake, but optional test targets are
# provided to validate cross-compilation infrastructure.
project(386BSD C)

option(BUILD_DOCS "Build documentation with Doxygen and Sphinx" ON)
option(BUILD_TESTS "Build auxiliary test binaries" ON)

if(BUILD_DOCS)
  add_subdirectory(docs)
endif()

if(BUILD_TESTS)
  add_subdirectory(tests)
endif()
