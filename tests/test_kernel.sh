#!/bin/sh
set -eu
# Determine repository root as the parent directory of this script
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

# Perform a dry-run build to ensure Makefiles parse correctly
bmake -C usr/src -n > /dev/null

# Check that the kernel image exists. Building the full 386BSD kernel is
# outside the scope of these lightweight tests, so absence of the image is
# reported as a warning rather than a hard failure.
if [ ! -f 386bsd ]; then
  echo "Kernel image 386bsd not found; skipping presence check" >&2
  exit 0
fi

echo "Kernel image present: $(ls -l 386bsd)"
