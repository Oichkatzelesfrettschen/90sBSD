cmake_minimum_required(VERSION 3.16)

# Documentation build configuration. This file wires together
# Doxygen for C/C++ API extraction and Sphinx via the Breathe
# bridge so that both toolchains are driven from CMake.
project(Documentation NONE)

find_package(Doxygen REQUIRED)
find_program(SPHINX_EXECUTABLE sphinx-build REQUIRED)

# Configure the Doxygen input using a template to allow CMake
# variables such as the source directory to be injected.
set(DOXYGEN_IN  ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
set(DOXYGEN_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)
configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)

add_custom_target(doxygen
    COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_OUT}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generate API documentation with Doxygen"
    VERBATIM)

# Build the Sphinx documentation. We depend on Doxygen so that
# API XML is available to the Breathe extension.
add_custom_target(sphinx
    COMMAND ${SPHINX_EXECUTABLE} -b html
            -Dbreathe_projects.386bsd=${CMAKE_CURRENT_BINARY_DIR}/doxygen/xml
            ${CMAKE_CURRENT_SOURCE_DIR}
            ${CMAKE_CURRENT_BINARY_DIR}/html
    DEPENDS doxygen
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMENT "Generate HTML documentation with Sphinx"
    VERBATIM)
