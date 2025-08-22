#!/bin/sh
# Verify the include-audit utility resolves headers for a simple component.
set -e
python3 scripts/scan-includes.py usr/src/bin/echo \
  -I usr/include -I usr/src/include -I usr/src/lib/libc/include \
  --compile-commands build/compile_commands.json \
  --json > /tmp/include_audit.json
# Ensure output is valid JSON by invoking python's json.tool
python3 -m json.tool < /tmp/include_audit.json > /dev/null
