# 386BSD Tool Installation Guide

**For Ubuntu 24.04 (Noble Numbat)**
**Updated**: 2025-11-17

---

## 🎯 Good News: No PPAs Required!

All required tools are available in **official Ubuntu 24.04 repositories**. No third-party PPAs needed!

---

## 📦 Required Tools Status

### Available in Ubuntu 24.04 Official Repos ✅

| Tool | Package | Repository | Version | Purpose |
|------|---------|------------|---------|---------|
| **bmake** | `bmake` | universe | 20200710-16 | BSD Make (legacy builds) |
| **QEMU i386** | `qemu-system-x86` | main | 1:8.2.2+ | i386 emulation |
| **QEMU Utils** | `qemu-utils` | main | 1:8.2.2+ | Disk image tools |
| **Flex** | `flex` | main | 2.6.4-8.2 | Lexical analyzer |
| **Groff** | `groff` | main | 1.23.0-3 | Text formatting |
| **GCC Multilib** | `gcc-multilib` | main | 4:13.2.0-7 | 32-bit compilation |
| **32-bit libc** | `libc6-dev-i386` | main | 2.39-0 | 32-bit C library |
| **Bison** | `bison` | main | 3.8.2+ | Parser generator |
| **BSD Utils** | `bsdutils` | main | Latest | BSD utilities |
| **Clang/LLVM** | `clang` | main | 18.1.3 | Modern C compiler |

---

## 🚀 One-Command Installation

### Complete Toolchain Setup

```bash
# Enable universe repository (if not already enabled)
sudo add-apt-repository universe
sudo apt update

# Install all required tools
sudo apt install -y \
  bmake \
  qemu-system-x86 \
  qemu-utils \
  flex \
  bison \
  groff \
  gcc-multilib \
  libc6-dev-i386 \
  clang \
  clang-tools \
  lld \
  llvm \
  bsdutils \
  build-essential \
  git \
  rsync \
  python3 \
  python3-pip

# Install documentation tools (optional)
sudo apt install -y \
  doxygen \
  graphviz \
  python3-sphinx

pip3 install --user breathe sphinx-rtd-theme
```

### Verify Installation

```bash
# Check all tools
bmake -version
qemu-system-i386 --version
flex --version
groff --version
gcc -v
clang --version
bison --version

# Check 32-bit compilation support
echo "int main() { return 0; }" | gcc -m32 -x c - -o /tmp/test32 && echo "32-bit OK" || echo "32-bit FAILED"
```

---

## 🔧 Alternative: LLVM Official Repository (Latest Versions)

For the **absolute latest** LLVM/Clang versions, use the official LLVM apt repository:

### Add LLVM Repository

```bash
# Download and add LLVM GPG key
wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key | sudo tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc

# Add repository (for Ubuntu 24.04 Noble)
echo "deb http://apt.llvm.org/noble/ llvm-toolchain-noble main" | sudo tee /etc/apt/sources.list.d/llvm.list

sudo apt update

# Install latest LLVM/Clang
sudo apt install -y \
  clang-19 \
  llvm-19 \
  lld-19 \
  llvm-19-dev \
  llvm-19-tools

# Set as default
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-19 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-19 100
```

**Note**: This is **optional**. Clang 18.1.3 from Ubuntu repos is sufficient for 386BSD.

---

## 🐳 Alternative: Docker (No Sudo Required)

If you don't have sudo access, use Docker:

### Using Existing Docker Container

```bash
# Use the 386BSD dev container
docker build -f .github/containers/Dockerfile.dev -t 386bsd-dev .
docker run -it --rm -v $PWD:/workspace 386bsd-dev

# Or use docker-compose
docker-compose up dev
```

### Custom Docker Image

```dockerfile
FROM ubuntu:24.04

# Install all tools
RUN apt-get update && apt-get install -y \
    bmake \
    qemu-system-x86 \
    qemu-utils \
    flex \
    bison \
    groff \
    gcc-multilib \
    libc6-dev-i386 \
    clang \
    lld \
    llvm \
    build-essential \
    git \
    rsync \
    python3 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["/bin/bash"]
```

```bash
docker build -t 386bsd-tools .
docker run -it --rm -v $PWD:/workspace 386bsd-tools
```

---

## 📋 Tool Purposes & Usage

### bmake (BSD Make)
```bash
# Required for legacy BSD Makefiles
cd usr/src/kernel
bmake clean
bmake depend
bmake all
```

**Why needed**: Original 386BSD uses BSD-style Makefiles incompatible with GNU Make.

### qemu-system-i386
```bash
# Boot kernel in i386 emulation
qemu-system-i386 \
  -M pc \
  -cpu 486 \
  -m 64M \
  -kernel usr/src/kernel/386bsd \
  -nographic
```

**Why needed**: Test 386BSD kernel without real hardware.

### gcc-multilib + libc6-dev-i386
```bash
# Compile 32-bit code on 64-bit system
gcc -m32 -march=i386 -o program program.c
```

**Why needed**: 386BSD is 32-bit i386, modern systems are 64-bit.

### flex + bison
```bash
# Generate parsers and lexers
flex scanner.l
bison parser.y
```

**Why needed**: Kernel and userland have lexer/parser files.

### groff
```bash
# Format man pages
groff -man -Tascii page.1 | less
```

**Why needed**: BSD documentation uses troff/groff format.

---

## 🎯 Minimal Installation (Just to Build)

If you only need to **build the kernel**, minimum requirements:

```bash
sudo apt install -y \
  bmake \
  gcc-multilib \
  libc6-dev-i386 \
  clang \
  lld \
  bison \
  flex
```

---

## 🧪 Testing QEMU Installation

### Create Test Kernel Boot

```bash
# Install QEMU
sudo apt install qemu-system-x86

# Test with a minimal boot
qemu-system-i386 -M pc -cpu 486 -m 16M -nographic -kernel /boot/vmlinuz-$(uname -r)

# Press Ctrl+A then X to exit
```

### Create Virtual Disk

```bash
# Install qemu-utils
sudo apt install qemu-utils

# Create 512MB disk
qemu-img create -f qcow2 386bsd-disk.qcow2 512M

# Check info
qemu-img info 386bsd-disk.qcow2
```

---

## 📊 Package Availability Matrix

| Tool | Ubuntu 24.04 | Debian 12 | Fedora 40 | Arch Linux |
|------|-------------|-----------|-----------|------------|
| bmake | ✅ universe | ✅ main | ✅ | ✅ AUR |
| qemu-system-x86 | ✅ main | ✅ main | ✅ | ✅ |
| gcc-multilib | ✅ main | ✅ main | ⚠️ glibc-devel.i686 | ✅ multilib |
| clang | ✅ 18.1.3 | ✅ 14 | ✅ 18 | ✅ latest |
| flex | ✅ main | ✅ main | ✅ | ✅ |
| bison | ✅ main | ✅ main | ✅ | ✅ |
| groff | ✅ main | ✅ main | ✅ | ✅ |

---

## 🚨 Troubleshooting

### "Package bmake not found"

**Solution**: Enable universe repository

```bash
sudo add-apt-repository universe
sudo apt update
sudo apt install bmake
```

### "Cannot find -lc (32-bit)"

**Solution**: Install 32-bit development files

```bash
sudo apt install gcc-multilib libc6-dev-i386
```

### "qemu-system-i386: command not found"

**Solution**: Install QEMU x86 system emulator

```bash
sudo apt install qemu-system-x86
```

### Flex/Bison Not Found

**Solution**: Install development tools

```bash
sudo apt install flex bison
```

---

## 🔍 Checking What's Installed

### Quick Check Script

```bash
#!/bin/bash
echo "=== Tool Installation Check ==="
echo ""

tools=("bmake" "qemu-system-i386" "flex" "bison" "groff" "gcc" "clang")

for tool in "${tools[@]}"; do
    if command -v "$tool" &> /dev/null; then
        version=$($tool --version 2>&1 | head -1)
        echo "✅ $tool: $version"
    else
        echo "❌ $tool: NOT INSTALLED"
    fi
done

# Check 32-bit support
echo ""
echo "=== 32-bit Compilation Support ==="
if echo "int main() { return 0; }" | gcc -m32 -x c - -o /tmp/test32 2>/dev/null; then
    echo "✅ 32-bit compilation: OK"
    rm -f /tmp/test32
else
    echo "❌ 32-bit compilation: FAILED (install gcc-multilib libc6-dev-i386)"
fi
```

---

## 📅 Installation Checklist

Before starting Phase 5:

- [ ] Universe repository enabled
- [ ] `bmake` installed and working
- [ ] `qemu-system-i386` installed
- [ ] `qemu-utils` installed (qemu-img)
- [ ] `gcc-multilib` + `libc6-dev-i386` installed
- [ ] 32-bit compilation test passes
- [ ] `clang` installed (18.1.3 or newer)
- [ ] `flex` and `bison` installed
- [ ] `groff` installed
- [ ] `git` and `rsync` available

---

## 🎬 Post-Installation: Verify Setup

```bash
# Run the automated build check
./scripts/build-troubleshoot.sh --check-tools

# Or manual check
cd /home/user/386bsd
bmake --version              # Should show NetBSD Make
qemu-system-i386 --version   # Should show QEMU 8.2.2+
gcc -m32 --version           # Should compile 32-bit
clang --version              # Should show 18.1.3
```

---

## 🏁 Ready for Phase 5!

Once all tools are installed:

```bash
# Start Phase 5 Day 1
cd /home/user/386bsd

# Import headers
./scripts/import-from-bsd.sh \
    ../bsd-sources/4.4BSD-Lite2 \
    usr/src/sys/sys \
    usr/src/kernel/include/sys

# Build kernel
cd usr/src/kernel
bmake clean && bmake depend && bmake all
```

---

**Last Updated**: 2025-11-17
**Status**: All tools available in Ubuntu 24.04 official repos
**No PPAs Required**: ✅

---
