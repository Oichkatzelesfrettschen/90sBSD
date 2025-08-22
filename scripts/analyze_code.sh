#!/bin/sh
#
# analyze_code.sh - static analysis toolkit for the 386BSD source tree
#
# This script demonstrates language statistics, dialect checks, and
# basic static analysis with tools configured for C89 semantics. The
# goal is to surface legacy K&R constructs and other technical debt.
#
set -eu

# Repository root
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

printf '%s\n' '== Language statistics (cloc) =='
cloc usr/src | head -n 20

printf '%s\n' '\n== cppcheck (C89 dialect) =='
CPPCHECK_TARGET="${CPPCHECK_TARGET:-usr/src}"
cppcheck --std=c89 "$CPPCHECK_TARGET" 2> cppcheck.log
# Display tail of log for brevity
if [ -s cppcheck.log ]; then
  tail -n 20 cppcheck.log
fi

printf '%s\n' '\n== clang-tidy (C89 dialect) =='
CLANG_TIDY_TARGET="${CLANG_TIDY_TARGET:-usr/src/kernel/route/radix.c}"
clang-tidy "$CLANG_TIDY_TARGET" -- -std=c89 > clang_tidy.log || true
if [ -s clang_tidy.log ]; then
  tail -n 20 clang_tidy.log
fi
