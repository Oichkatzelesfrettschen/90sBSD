#!/bin/sh
# Generate API and user documentation. The logs are tailed so that
# CI systems provide concise output while still capturing errors.
set -e

cmake -S . -B build/docs > build_docs.log && tail -n 20 build_docs.log
cmake --build build/docs --target doxygen > doxygen.log && tail -n 20 doxygen.log
cmake --build build/docs --target sphinx > sphinx.log && tail -n 20 sphinx.log
