#!/bin/sh
set -eu
# Determine repository root as the parent directory of this script
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Perform a dry-run build to ensure makefiles parse correctly
bmake -C usr/src -n > /dev/null

# Check that the kernel image exists
if [ ! -f 386bsd ]; then
  echo "Kernel image 386bsd not found" >&2
  exit 1
fi

echo "Kernel image present: $(ls -l 386bsd)"
