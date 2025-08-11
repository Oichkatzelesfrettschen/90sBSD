# ccwrap

Compiler wrapper enforcing i386 ELF cross flags.

```bash
#!/usr/bin/env bash
# ccwrap -- hermetic Clang invocation wrapper
set -euo pipefail
: "${SYSROOT:?set SYSROOT first}"
exec clang --target=i386-unknown-elf --sysroot="$SYSROOT" \
  -ffreestanding -fno-builtin -m32 -march=i386 -mno-sse -mno-sse2 -mno-mmx \
  -msoft-float -fno-omit-frame-pointer -fno-stack-protector \
  -fno-asynchronous-unwind-tables "$@"
```
