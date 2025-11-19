# 386BSD Build Requirements

**Last Updated**: 2025-11-19
**Repository**: https://github.com/Oichkatzelesfrettschen/386bsd
**Branch**: claude/import-bsd-code-01F1Pq4n5DNwRAqu1dQrbH4d

---

## System Requirements

### Operating System
- **Tested**: Ubuntu 24.04 LTS (Noble Numbat)
- **Recommended**: Debian-based Linux distribution
- **Architecture**: x86_64 host (building for i386 target)

### Hardware Requirements
- **CPU**: x86_64 with 32-bit support
- **RAM**: Minimum 4GB (8GB recommended for parallel builds)
- **Disk**: 10GB free space (20GB recommended)
- **Architecture Support**: i386 multilib support required

---

## Core Build Tools

### Compiler Toolchain

| Package | Version | Purpose | Installation |
|---------|---------|---------|--------------|
| **gcc** | 11.x - 13.x | C compiler | `apt-get install gcc` |
| **g++** | 11.x - 13.x | C++ compiler (for build tools) | `apt-get install g++` |
| **gcc-multilib** | Matches gcc | 32-bit compilation support | `apt-get install gcc-multilib` |
| **g++-multilib** | Matches g++ | 32-bit C++ support | `apt-get install g++-multilib` |
| **binutils** | 2.38+ | GNU assembler, linker, utilities | `apt-get install binutils` |
| **make** | 4.3+ | GNU Make (for some utilities) | `apt-get install make` |

**Critical**: All compiler toolchain packages must support i386 target architecture.

### BSD Make System

| Package | Version | Purpose | Installation |
|---------|---------|---------|--------------|
| **bmake** | 20200710+ | Berkeley Make (primary build system) | `apt-get install bmake` |
| **libbsd-dev** | Latest | BSD compatibility library headers | `apt-get install libbsd-dev` |

**Note**: The project uses BSD Make (bmake) as the primary build system. GNU Make is only used for select utilities.

### Development Headers

| Package | Purpose | Installation |
|---------|---------|--------------|
| **linux-libc-dev:i386** | Linux kernel headers (32-bit) | `dpkg --add-architecture i386 && apt-get install linux-libc-dev:i386` |
| **libc6-dev-i386** | C library development files (32-bit) | `apt-get install libc6-dev-i386` |

---

## Build Utilities

### Required Utilities

| Package | Version | Purpose | Verification |
|---------|---------|---------|--------------|
| **bash** | 5.0+ | Shell scripting | `bash --version` |
| **coreutils** | 8.30+ | Core Unix utilities (ls, cp, mv, etc.) | `ls --version` |
| **findutils** | 4.8+ | File search utilities | `find --version` |
| **grep** | 3.7+ | Pattern matching | `grep --version` |
| **sed** | 4.8+ | Stream editor | `sed --version` |
| **gawk** | 5.1+ | AWK text processing | `gawk --version` |
| **diff** | 3.8+ | File comparison | `diff --version` |
| **patch** | 2.7+ | Apply patches | `patch --version` |

### Archive and Compression

| Package | Purpose | Installation |
|---------|---------|--------------|
| **tar** | Tape archive utility | `apt-get install tar` |
| **gzip** | Compression | `apt-get install gzip` |
| **bzip2** | Compression | `apt-get install bzip2` |
| **xz-utils** | Compression | `apt-get install xz-utils` |

---

## Version Control

| Package | Version | Purpose | Installation |
|---------|---------|---------|--------------|
| **git** | 2.34+ | Version control | `apt-get install git` |
| **git-lfs** | Latest | Large file support | `apt-get install git-lfs` |

**Configuration**:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

---

## Documentation Tools

### Documentation Generation

| Package | Purpose | Installation |
|---------|---------|--------------|
| **doxygen** | API documentation from C code | `apt-get install doxygen` |
| **graphviz** | Dependency graphs for Doxygen | `apt-get install graphviz` |
| **python3-sphinx** | Documentation framework | `apt-get install python3-sphinx` |
| **python3-sphinx-rtd-theme** | ReadTheDocs theme | `apt-get install python3-sphinx-rtd-theme` |

### Manual Page Tools

| Package | Purpose | Installation |
|---------|---------|--------------|
| **groff** | Text formatting (man pages) | `apt-get install groff` |
| **mandoc** | BSD manual page formatter | `apt-get install mandoc` |

---

## Testing and Analysis

### Static Analysis

| Package | Purpose | Installation |
|---------|---------|--------------|
| **cppcheck** | Static C/C++ analyzer | `apt-get install cppcheck` |
| **clang-tidy** | Clang-based linter | `apt-get install clang-tidy` |
| **clang-format** | Code formatter | `apt-get install clang-format` |

### Runtime Analysis

| Package | Purpose | Installation |
|---------|---------|--------------|
| **valgrind** | Memory debugging | `apt-get install valgrind` |
| **gdb** | GNU Debugger | `apt-get install gdb` |
| **strace** | System call tracer | `apt-get install strace` |

---

## Emulation and Testing

### QEMU

| Package | Purpose | Installation |
|---------|---------|--------------|
| **qemu-system-x86** | i386 emulation | `apt-get install qemu-system-x86` |
| **qemu-utils** | QEMU utilities | `apt-get install qemu-utils` |

**Verification**:
```bash
qemu-system-i386 --version
```

---

## Python Dependencies

### Core Python

| Package | Version | Purpose | Installation |
|---------|---------|---------|--------------|
| **python3** | 3.10+ | Python interpreter | `apt-get install python3` |
| **python3-pip** | Latest | Python package installer | `apt-get install python3-pip` |
| **python3-venv** | Latest | Virtual environments | `apt-get install python3-venv` |

### Python Packages (via pip)

| Package | Version | Purpose | Installation |
|---------|---------|---------|--------------|
| **breathe** | Latest | Doxygen-Sphinx bridge | `pip3 install breathe` |
| **sphinx-markdown-tables** | Latest | Markdown table support | `pip3 install sphinx-markdown-tables` |

---

## Optional but Recommended

### Code Quality

| Package | Purpose | Installation |
|---------|---------|--------------|
| **ccache** | Compiler cache (speeds up rebuilds) | `apt-get install ccache` |
| **colordiff** | Colorized diff output | `apt-get install colordiff` |
| **tree** | Directory tree visualization | `apt-get install tree` |

### Development Utilities

| Package | Purpose | Installation |
|---------|---------|--------------|
| **vim** or **nano** | Text editors | `apt-get install vim` |
| **curl** | HTTP client | `apt-get install curl` |
| **wget** | File downloader | `apt-get install wget` |
| **rsync** | File synchronization | `apt-get install rsync` |

---

## Installation Scripts

### Quick Install (Ubuntu 24.04)

```bash
#!/bin/bash
# 386BSD Build Requirements Installation
# For Ubuntu 24.04 LTS

set -e

echo "Installing 386BSD build requirements..."

# Enable i386 architecture
sudo dpkg --add-architecture i386
sudo apt-get update

# Core toolchain
sudo apt-get install -y \
    gcc g++ gcc-multilib g++-multilib \
    binutils make bmake \
    libbsd-dev

# 32-bit development libraries
sudo apt-get install -y \
    linux-libc-dev:i386 \
    libc6-dev-i386

# Build utilities
sudo apt-get install -y \
    bash coreutils findutils grep sed gawk \
    diff patch tar gzip bzip2 xz-utils

# Version control
sudo apt-get install -y git git-lfs

# Documentation
sudo apt-get install -y \
    doxygen graphviz groff mandoc \
    python3-sphinx python3-sphinx-rtd-theme

# Testing and analysis
sudo apt-get install -y \
    cppcheck clang-tidy clang-format \
    valgrind gdb strace

# QEMU emulation
sudo apt-get install -y \
    qemu-system-x86 qemu-utils

# Python and packages
sudo apt-get install -y \
    python3 python3-pip python3-venv

pip3 install --user breathe sphinx-markdown-tables

# Optional but recommended
sudo apt-get install -y \
    ccache colordiff tree vim curl wget rsync

echo "Installation complete!"
echo "Verify with: bmake --version && gcc --version && qemu-system-i386 --version"
```

### Verification Script

```bash
#!/bin/bash
# Verify 386BSD build requirements

echo "=== 386BSD Build Requirements Verification ==="
echo

# Compiler toolchain
echo "Compiler Toolchain:"
gcc --version | head -1
g++ --version | head -1
gcc -m32 --version | head -1 || echo "ERROR: 32-bit compilation not supported"
echo

# Build systems
echo "Build Systems:"
bmake --version 2>&1 | head -1
make --version | head -1
echo

# Architecture support
echo "Architecture Support:"
dpkg --print-foreign-architectures | grep i386 && echo "i386 architecture enabled" || echo "WARNING: i386 not enabled"
echo

# QEMU
echo "Emulation:"
qemu-system-i386 --version | head -1
echo

# Python
echo "Python:"
python3 --version
pip3 --version
echo

# Documentation
echo "Documentation Tools:"
doxygen --version | head -1
dot -V 2>&1 | head -1
sphinx-build --version
echo

# Analysis tools
echo "Analysis Tools:"
cppcheck --version | head -1
gdb --version | head -1
echo

echo "=== Verification Complete ==="
```

---

## Environment Variables

### Required Environment Variables

```bash
# None required for basic build
```

### Recommended Environment Variables

```bash
# Enable ccache for faster rebuilds
export CC="ccache gcc"
export CXX="ccache g++"

# Parallel builds (adjust -j based on CPU cores)
export MAKEFLAGS="-j$(nproc)"

# Colorized output
export CLICOLOR=1
```

---

## Build Configuration

### Compiler Flags (already in build system)

The build system automatically sets:
- `-m32`: 32-bit compilation
- `-fno-builtin`: Disable built-in functions
- `-fno-stack-protector`: Disable stack protector
- `-fno-pic`: Disable position-independent code
- `-Wno-implicit-int`: Suppress legacy warnings (will be fixed)

### Assembler Flags

- `--32`: 32-bit assembly mode

---

## Known Issues and Workarounds

### Issue 1: Modern GCC Compatibility

**Problem**: 386BSD was written for older compilers.

**Workaround**: Build system includes compatibility flags (`-m32`, `--32`, `-fno-builtin`, etc.)

### Issue 2: ELF vs. a.out Symbol Naming

**Problem**: Legacy code expects a.out underscore-prefixed symbols; modern toolchains use ELF.

**Workaround**: Symbol aliases created in assembly files (see `usr/src/kernel/kern/i386/locore.s`)

### Issue 3: Missing System Headers

**Problem**: Some legacy BSD headers conflict with modern Linux headers.

**Workaround**: Project includes compatibility headers in `usr/src/include/`

### Issue 4: 32-bit Library Dependencies

**Problem**: Modern 64-bit systems don't include 32-bit libraries by default.

**Solution**: Install `gcc-multilib`, `g++-multilib`, and enable i386 architecture

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-11-19 | 1.0.0 | Initial comprehensive requirements documentation |

---

## References

- [BUILD_ISSUES.md](BUILD_ISSUES.md) - Common build problems and solutions
- [TOOL_INSTALLATION_GUIDE.md](TOOL_INSTALLATION_GUIDE.md) - Detailed Ubuntu 24.04 setup
- [docs/getting-started/installation.md](docs/getting-started/installation.md) - Installation guide (TBD)
- [Code Markers Report](CODE_MARKERS_REPORT.md) - Known issues in codebase

---

## Contact and Support

- **Issues**: https://github.com/Oichkatzelesfrettschen/386bsd/issues
- **Documentation**: https://github.com/Oichkatzelesfrettschen/386bsd/tree/main/docs

---

**Note**: This document will be updated as new dependencies are discovered during development. Always verify requirements before starting a build.
