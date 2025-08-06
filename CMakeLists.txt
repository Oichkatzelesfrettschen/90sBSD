cmake_minimum_required(VERSION 3.16)

# Top-level CMake entry point for 386BSD. At present the build
# system is used solely for documentation generation and does not
# attempt to replace the historical makefiles.
project(386BSD NONE)

add_subdirectory(docs)
