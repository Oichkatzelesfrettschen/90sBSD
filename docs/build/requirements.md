# 386BSD Build and Development Requirements

**Document Version**: 1.0
**Last Updated**: 2025-11-19
**Status**: Living Document - Updated as requirements evolve

---

## Table of Contents

1. [System Requirements](#system-requirements)
2. [Compiler Toolchain](#compiler-toolchain)
3. [Build Tools](#build-tools)
4. [Analysis and Quality Tools](#analysis-and-quality-tools)
5. [Testing Infrastructure](#testing-infrastructure)
6. [Documentation Tools](#documentation-tools)
7. [Module-Specific Requirements](#module-specific-requirements)
8. [Validation Checklist](#validation-checklist)
9. [Troubleshooting](#troubleshooting)
10. [Installation Guides](#installation-guides)

---

## System Requirements

### Host System

**Supported Operating Systems**:
- ✅ **Ubuntu 24.04 LTS** (recommended, primary development platform)
- ✅ **Debian 12+** (fully supported)
- ✅ **Fedora 38+** (supported)
- ⚠️  **macOS** (partial support - BSD utilities differ)
- ⚠️  **Other BSDs** (FreeBSD, OpenBSD - should work but untested)

**Hardware Requirements**:
- **Architecture**: x86_64 (for cross-compilation to i386)
- **RAM**: Minimum 4GB, **recommended 8GB+**
- **Disk Space**:
  - Source: ~100 MB
  - Build artifacts: ~2 GB
  - Full build + tests: ~10 GB recommended
- **CPU**: Multi-core recommended for parallel builds

**Verification**:
```bash
# Check system
uname -a
# Should show: Linux ... x86_64

# Check available disk space
df -h /home/user/386bsd
# Should show >10GB available

# Check RAM
free -h
# Recommended: >8GB total
```

---

## Compiler Toolchain

### C Compiler: Clang/LLVM

**Required Version**: Clang 15.0 or later

**Rationale**:
- C17 support requires Clang 9.0+
- Clang 15+ recommended for:
  - Better C17 conformance
  - Improved sanitizers (ASan, UBSan, TSan)
  - Enhanced static analysis
  - Better diagnostics

**Installation (Ubuntu 24.04)**:
```bash
# Install Clang 15 (or later)
sudo apt update
sudo apt install -y clang-15 llvm-15

# Verify installation
clang-15 --version
# Should show: clang version 15.0.0 or later

# Create symlinks for convenience
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 100
```

**Required Clang Features**:
- [x] `-std=c17` support
- [x] `-fsanitize=address,undefined,thread`
- [x] `-pedantic` mode
- [x] Cross-compilation to i386 (`-m32`)

**Verification**:
```bash
# Test C17 support
echo 'int main() { return 0; }' > /tmp/test.c
clang -std=c17 -pedantic -Wall -Werror /tmp/test.c -o /tmp/test
# Should compile without errors

# Test 32-bit cross-compilation
clang -m32 -std=c17 /tmp/test.c -o /tmp/test32
# Should compile (may need gcc-multilib)

# Test sanitizer support
clang -std=c17 -fsanitize=address /tmp/test.c -o /tmp/test_asan
# Should compile
```

### Linker: LLD

**Required Version**: LLD 15.0+

**Installation (Ubuntu 24.04)**:
```bash
sudo apt install -y lld-15

# Verify
lld-15 --version
# Should show: LLD 15.0.0 or later

# Create symlink
sudo update-alternatives --install /usr/bin/ld.lld ld.lld /usr/bin/lld-15 100
```

### Additional Toolchain Components

**Required**:
```bash
# LLVM tools
sudo apt install -y \
    llvm-15 \
    llvm-15-dev \
    llvm-15-tools \
    llvm-ar-15 \
    llvm-ranlib-15

# Create symlinks
sudo ln -sf /usr/bin/llvm-ar-15 /usr/local/bin/llvm-ar
sudo ln -sf /usr/bin/llvm-ranlib-15 /usr/local/bin/llvm-ranlib
```

**32-bit Support** (for i386 cross-compilation):
```bash
# Install 32-bit development libraries
sudo apt install -y gcc-multilib g++-multilib

# Verify 32-bit support
echo 'int main() { return 0; }' | clang -m32 -x c - -o /tmp/test32
file /tmp/test32
# Should show: ELF 32-bit LSB executable, Intel 80386
```

---

## Build Tools

### BSD Make (BMAKE)

**Required Version**: bmake 20200710 or later

**Installation**:

**Option 1: Ubuntu/Debian Package**:
```bash
sudo apt install -y bmake

# Verify
bmake --version
# Should show version info
```

**Option 2: From Source** (if package unavailable):
```bash
# Download and build bmake
wget http://www.crufty.net/ftp/pub/sjg/bmake-20220909.tar.gz
tar xzf bmake-20220909.tar.gz
cd bmake
./configure --prefix=/usr/local
make
sudo make install

# Verify
bmake --version
```

**Verification**:
```bash
cd /home/user/386bsd/usr/src
bmake clean
# Should execute without errors
```

### Ninja Build System

**Required for**: CMake-based builds (optional subsystems)

**Installation**:
```bash
sudo apt install -y ninja-build

# Verify
ninja --version
# Should show: 1.10.0 or later
```

### CMake

**Required Version**: 3.20+

**Installation**:
```bash
sudo apt install -y cmake

# Verify
cmake --version
# Should show: cmake version 3.20.0 or later
```

### Python 3

**Required Version**: Python 3.10+

**Purpose**: Build scripts, analysis tools, automation

**Installation**:
```bash
sudo apt install -y python3 python3-pip python3-venv

# Verify
python3 --version
# Should show: Python 3.10.0 or later
```

**Required Python Packages**:
```bash
# Install with pip
pip3 install --user \
    pyyaml \
    jinja2 \
    click

# Or use system packages
sudo apt install -y \
    python3-yaml \
    python3-jinja2 \
    python3-click
```

---

## Analysis and Quality Tools

### Static Analysis

#### clang-tidy

**Purpose**: C17 conformance checking, modernization suggestions

**Installation**:
```bash
sudo apt install -y clang-tidy-15

# Verify
clang-tidy-15 --version
```

**Configuration**: `.clang-tidy` file in repository root

#### cppcheck

**Purpose**: Additional static analysis, bug detection

**Installation**:
```bash
sudo apt install -y cppcheck

# Verify
cppcheck --version
# Should show: Cppcheck 2.7 or later
```

#### scan-build

**Purpose**: Clang static analyzer

**Installation**:
```bash
sudo apt install -y clang-tools-15

# Verify
scan-build-15 --help
```

### Code Formatting

#### clang-format

**Purpose**: Consistent code formatting

**Installation**:
```bash
sudo apt install -y clang-format-15

# Verify
clang-format-15 --version
```

**Configuration**: `.clang-format` file in repository root

### Runtime Analysis

#### AddressSanitizer (ASan)

**Purpose**: Memory error detection (buffer overflows, use-after-free, etc.)

**Availability**: Built into Clang 15+

**Usage**:
```bash
bmake CFLAGS="-std=c17 -fsanitize=address -fno-omit-frame-pointer -g"
```

#### UndefinedBehaviorSanitizer (UBSan)

**Purpose**: Undefined behavior detection

**Availability**: Built into Clang 15+

**Usage**:
```bash
bmake CFLAGS="-std=c17 -fsanitize=undefined -g"
```

#### ThreadSanitizer (TSan)

**Purpose**: Race condition detection

**Availability**: Built into Clang 15+

**Usage**:
```bash
bmake CFLAGS="-std=c17 -fsanitize=thread -g"
```

**Note**: Cannot combine ASan with TSan in same build

---

## Testing Infrastructure

### POSIX Test Suite (LTP)

**Purpose**: POSIX.1-2017 conformance validation

**Installation**:
```bash
# Clone LTP
git clone https://github.com/linux-test-project/ltp.git
cd ltp

# Build and install
./configure --prefix=/opt/ltp
make -j$(nproc)
sudo make install

# Verify
/opt/ltp/runltp --help
```

**Usage**:
```bash
# Run POSIX tests
cd /opt/ltp
./runltp -f posix -o /tmp/ltp-results.txt
```

### Code Coverage

#### lcov/gcov

**Purpose**: Code coverage measurement

**Installation**:
```bash
sudo apt install -y lcov

# Verify
lcov --version
```

**Usage**:
```bash
# Build with coverage
bmake CFLAGS="-std=c17 --coverage -g"

# Run tests
bmake test

# Generate coverage report
lcov --capture --directory . --output-file coverage.info
genhtml coverage.info --output-directory coverage_html
```

---

## Documentation Tools

### Doxygen

**Purpose**: API documentation generation from source code

**Installation**:
```bash
sudo apt install -y doxygen graphviz

# Verify
doxygen --version
# Should show: 1.9.0 or later
```

**Configuration**: `Doxyfile` in docs/ directory

### Sphinx (Optional)

**Purpose**: Advanced documentation building

**Installation**:
```bash
pip3 install --user sphinx sphinx-rtd-theme

# Verify
sphinx-build --version
```

---

## Module-Specific Requirements

### Kernel (`usr/src/kernel/`)

**Headers Required**:
- `<stdint.h>` - Fixed-width types (C99+)
- `<stdatomic.h>` - Atomic operations (C11+)
- `<stdnoreturn.h>` - `_Noreturn` qualifier (C11+)
- `<stdalign.h>` - Alignment support (C11+)
- `<stdbool.h>` - Boolean type (C99+)

**Build Flags**:
```makefile
CFLAGS += -std=c17 \
          -ffreestanding \
          -fno-builtin \
          -fno-stack-protector \
          -m32 \
          -march=i386 \
          -mno-sse \
          -mno-sse2 \
          -msoft-float
```

**Dependencies**:
- None (freestanding environment)

### Libc (`usr/src/lib/libc/`)

**Standards Compliance**:
- ISO C17 (ISO/IEC 9899:2018)
- POSIX.1-2017 (IEEE Std 1003.1-2017)
- SUSv4 (Single UNIX Specification, Version 4)

**Build Flags**:
```makefile
CFLAGS += -std=c17 \
          -D_POSIX_C_SOURCE=200809L \
          -D_XOPEN_SOURCE=700
```

**Dependencies**:
- System call interface (kernel)
- Standard headers

### Userland Utilities (`usr/src/bin/`, `usr/src/sbin/`)

**Build Flags**:
```makefile
CFLAGS += -std=c17 \
          -D_XOPEN_SOURCE=700 \
          -D_DEFAULT_SOURCE
```

**Dependencies**: Vary by utility

---

## Validation Checklist

### Initial Setup

```bash
# 1. Verify host system
uname -a | grep "x86_64"        # ✓ 64-bit system
free -h | grep "Mem:"           # ✓ >4GB RAM
df -h | grep "386bsd"           # ✓ >10GB available

# 2. Verify compiler toolchain
clang --version | grep "clang version 1[5-9]"   # ✓ Clang 15+
lld --version | grep "LLD"                      # ✓ LLD installed
llvm-ar --version                               # ✓ LLVM tools

# 3. Verify build tools
bmake --version                                 # ✓ bmake installed
cmake --version | grep "cmake version 3\.[2-9]" # ✓ CMake 3.20+
python3 --version | grep "Python 3\.1[0-9]"     # ✓ Python 3.10+

# 4. Verify analysis tools
clang-tidy --version                            # ✓ clang-tidy
cppcheck --version                              # ✓ cppcheck
clang-format --version                          # ✓ clang-format

# 5. Test compilation
cd /home/user/386bsd/usr/src
bmake clean                                     # ✓ Clean succeeds
bmake depend                                    # ✓ Depend succeeds
```

### Build System Validation

```bash
# Test C17 strict mode
echo 'int main(void) { return 0; }' > /tmp/test_c17.c
clang -std=c17 -pedantic -Wall -Werror /tmp/test_c17.c

# Test 32-bit cross-compilation
clang -m32 -std=c17 /tmp/test_c17.c -o /tmp/test32

# Test sanitizers
clang -std=c17 -fsanitize=address /tmp/test_c17.c
clang -std=c17 -fsanitize=undefined /tmp/test_c17.c
```

### Continuous Integration

See `.github/workflows/` for CI/CD pipelines

**Required Checks**:
- ✓ All tests passing
- ✓ Static analysis clean
- ✓ No sanitizer violations
- ✓ Code coverage >80%

---

## Troubleshooting

### Common Issues

#### Issue: "Cannot find -lgcc_s" during 32-bit build

**Solution**:
```bash
sudo apt install -y gcc-multilib g++-multilib lib32gcc-s1
```

#### Issue: "stdint.h: No such file or directory"

**Solution**: Verify Clang installation and 32-bit headers
```bash
sudo apt install -y clang-15 libc6-dev-i386
```

#### Issue: bmake not found

**Solution**: Install bmake or use make
```bash
sudo apt install -y bmake
# Or build from source (see above)
```

#### Issue: Sanitizer runtime missing

**Solution**:
```bash
sudo apt install -y libasan8 libubsan1 libtsan2
```

### Build Failures

See [BUILD_ISSUES.md](../../BUILD_ISSUES.md) for detailed troubleshooting

### Getting Help

1. Check documentation: `docs/`
2. Review build logs: `logs/build/`
3. Run diagnostics: `./scripts/build-troubleshoot.sh --full-check`
4. File issue: https://github.com/Oichkatzelesfrettschen/386bsd/issues

---

## Installation Guides

### Ubuntu 24.04 LTS (Recommended)

**Complete Setup**:
```bash
#!/bin/bash
# Complete 386BSD development environment setup for Ubuntu 24.04

set -e

echo "Installing 386BSD development requirements..."

# Update system
sudo apt update
sudo apt upgrade -y

# Install compiler toolchain
sudo apt install -y \
    clang-15 \
    llvm-15 \
    llvm-15-dev \
    llvm-15-tools \
    lld-15 \
    gcc-multilib \
    g++-multilib

# Install build tools
sudo apt install -y \
    bmake \
    ninja-build \
    cmake \
    python3 \
    python3-pip \
    python3-venv

# Install analysis tools
sudo apt install -y \
    clang-tidy-15 \
    clang-format-15 \
    clang-tools-15 \
    cppcheck

# Install documentation tools
sudo apt install -y \
    doxygen \
    graphviz

# Install runtime libraries
sudo apt install -y \
    libasan8 \
    libubsan1 \
    libtsan2 \
    lib32gcc-s1 \
    libc6-dev-i386

# Create symlinks
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 100
sudo update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-15 100
sudo update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-15 100

# Verify installation
echo ""
echo "Verifying installation..."
clang --version
bmake --version || echo "WARNING: bmake not found"
cmake --version
python3 --version

echo ""
echo "✓ Installation complete!"
echo "Run './scripts/build-troubleshoot.sh --full-check' to validate"
```

**Save as**: `scripts/install-deps-ubuntu.sh`

### Debian 12

Similar to Ubuntu, use apt-get instead of apt

### Fedora 38+

```bash
sudo dnf install -y \
    clang \
    llvm \
    lld \
    bmake \
    ninja-build \
    cmake \
    python3 \
    clang-tools-extra \
    cppcheck \
    doxygen \
    graphviz \
    glibc-devel.i686
```

---

## Update History

- **2025-11-19**: Initial version for C17/SUSv4 modernization
  - Defined all tool requirements
  - Added installation guides
  - Created validation checklists

---

## Maintainers

- Primary: 386BSD Modernization Team
- Contact: See repository README.md

---

**Document Status**: Official - Required for all development
**Next Review**: After Phase 0 completion (Week 4)
