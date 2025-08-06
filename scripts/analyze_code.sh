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
cppcheck --std=c89 usr/src/kernel/route/radix.c 2> cppcheck.log
# Display tail of log for brevity
if [ -s cppcheck.log ]; then
  tail -n 20 cppcheck.log
fi

printf '%s\n' '\n== clang-tidy (C89 dialect) =='
clang-tidy usr/src/kernel/route/radix.c -- -std=c89 > clang_tidy.log || true
if [ -s clang_tidy.log ]; then
  tail -n 20 clang_tidy.log
fi
