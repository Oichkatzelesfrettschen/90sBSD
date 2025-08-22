# 386BSD Cross Sysroot Setup

This document captures the tooling and steps used to assemble the i386 ELF
sysroot required for cross-compiling legacy 386BSD userland with modern LLVM
components.

## Host Packages

The development environment relies on the following Ubuntu 24.04 packages:

```
clang lld llvm cmake ninja-build python3 python3-pip rsync \
  build-essential ripgrep doxygen graphviz pandoc
```

These can be installed via:

```bash
sudo apt-get update
sudo apt-get install -y clang lld llvm cmake ninja-build \
  python3 python3-pip rsync build-essential ripgrep \
  doxygen graphviz pandoc
```

## Manual Sysroot Construction

With the prerequisites installed, the sysroot can be produced using standard
shell commands – no helper script is required.  The following sequence mirrors
the historical `make-sysroot.sh` behaviour while remaining transparent and easy
to modify.

```bash
# 1. choose a destination
export SYSROOT=$PWD/sysroots/386bsd-elf
mkdir -p "$SYSROOT/usr/include" "$SYSROOT/usr/lib"

# 2. install headers
rsync -aL --exclude 'nonstd/**' usr/include/ "$SYSROOT/usr/include/"
rsync -aL --exclude 'nonstd/**' usr/src/include/ "$SYSROOT/usr/include/"
rsync -aL --exclude 'nonstd/**' usr/src/lib/libc/include/ "$SYSROOT/usr/include/"

# 3. compile a freestanding libc
cd usr/src/lib/libc
find . -name '*.c' -print0 | while IFS= read -r -d '' f; do
  clang --target=i386-unknown-elf \
    -ffreestanding -fno-builtin -m32 -march=i386 \
    -mno-sse -mno-sse2 -mno-mmx -msoft-float \
    -nostdinc -isystem "$SYSROOT/usr/include" \
    -O2 -fno-omit-frame-pointer -fno-stack-protector \
    -c "$f" -o "${f##*/}.o"
done
llvm-ar rcs "$SYSROOT/usr/lib/libc.a" *.o
llvm-ranlib "$SYSROOT/usr/lib/libc.a"
rm *.o
cd -

# 4. sanity checks
test -f "$SYSROOT/usr/include/sys/cdefs.h"
test -f "$SYSROOT/usr/include/machine/ansi.h"
```

After these steps the directory referenced by `SYSROOT` holds headers under
`usr/include` and a minimal `libc.a` under `usr/lib` suitable for passing to
Clang via `--sysroot=$SYSROOT`.

