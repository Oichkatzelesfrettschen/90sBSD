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

## Sysroot Builder

The script `scripts/make-sysroot.sh` copies the repository's header sources into
`sysroots/386bsd-elf` and constructs a bootstrap `libc.a`.  Header installation
filters out broken `nonstd/` symlinks and verifies the presence of
`sys/cdefs.h` and `machine/ansi.h` to guarantee a minimal, freestanding
environment for Clang.

Invoke the script as:

```bash
SYSROOT=$PWD/sysroots/386bsd-elf ./scripts/make-sysroot.sh
```

On success a static `libc.a` will be produced at `$SYSROOT/usr/lib/` and the
full header tree will reside under `$SYSROOT/usr/include/`.

