# Building 386BSD on Apple Silicon M1

**Last Updated**: 2025-11-19

## 🎯 Overview

This guide explains the best practices for building this i386/x86 BSD kernel on Apple Silicon (ARM64) hardware.

## 📊 Performance Comparison

| Method | Relative Speed | Use Case | Setup Complexity |
|--------|---------------|----------|------------------|
| **Native macOS Cross-compile** | ~100% (baseline) | Quick iterations | Low ✅ |
| **Docker + Rosetta 2** | ~80-90% | Full builds | Medium |
| **Docker + QEMU** | ~20-25% | N/A (avoid) | Medium |
| **UTM x86 VM** | ~5-10% | Final testing only | High |

## 🚀 Recommended Approaches

### **Method 1: Docker with Rosetta 2** (Primary Development)

#### Prerequisites
```bash
# Option A: Enable Rosetta in Docker Desktop
# Open Docker Desktop → Settings → Features in development
# ✅ Enable "Use Rosetta for x86/amd64 emulation on Apple Silicon"

# Option B: Use Colima (Recommended - Better Performance)
brew install colima docker docker-compose
colima start --arch x86_64 --vz-rosetta --cpu 4 --memory 8 --disk 60
```

#### Build Commands
```bash
# Use the optimized Dockerfile
export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Build the container
docker build -f .devcontainer/Dockerfile.rosetta -t 386bsd-dev .

# Run interactive session
docker run -it --rm \
  --platform linux/amd64 \
  -v "$(pwd):/workspace" \
  386bsd-dev

# Inside container - compile kernel
cd /workspace/usr/src/kernel
gcc -m32 -march=i386 -ffreestanding -fno-builtin \
    -I./include -I./include/sys -I. -I./vm \
    -DKERNEL -Di386 \
    kern/config.c -c -o build/config.o
```

#### Performance Tips
- **Rosetta 2 provides 4-5x speedup** over QEMU
- Near-native performance for most operations
- File I/O may still have overhead

---

### **Method 2: Native macOS Cross-Compilation** (Quick Builds)

#### Prerequisites
```bash
# Install Xcode Command Line Tools (if not already)
xcode-select --install

# Or use Homebrew GCC
brew install gcc@13 qemu

# Verify cross-compilation support
clang --version  # Should show Apple clang with multi-arch support
```

#### Build Commands
```bash
# macOS clang supports cross-compilation natively
cd usr/src/kernel

# Compile single file
clang -m32 -march=i386 -target i386-pc-none-elf \
    -ffreestanding -fno-builtin -fno-stack-protector \
    -I./include -I./include/sys -I. -I./vm \
    -DKERNEL -Di386 \
    kern/config.c -c -o build/config.o

# Or use GCC from Homebrew
/opt/homebrew/bin/gcc-13 -m32 -march=i386 \
    -ffreestanding -fno-builtin \
    -I./include -I./include/sys -I. -I./vm \
    -DKERNEL -Di386 \
    kern/config.c -c -o build/config.o
```

#### Pros & Cons
✅ **Pros:**
- Fastest compilation (native ARM performance)
- No container overhead
- Uses your existing MacPorts/Homebrew setup

⚠️ **Cons:**
- May encounter macOS-specific quirks
- Some GNU extensions may not work identically
- Better for quick iteration than final builds

---

### **Method 3: QEMU x86 VM** (Final Testing Only)

#### Prerequisites
```bash
# Install QEMU or UTM
brew install qemu
# OR
brew install --cask utm
```

#### Usage
```bash
# Use existing boot script
./boot-qemu.sh

# Or manual QEMU command
qemu-system-i386 \
    -kernel build/kernel.elf \
    -m 128M \
    -serial stdio \
    -display none
```

#### When to Use
- ⚠️ **Only for final kernel boot testing**
- **Very slow** (10-20x slower than native)
- Most accurate x86 environment
- Required for actual boot verification

---

## 🔧 Recommended Workflow

### Daily Development Cycle
```bash
# 1. Quick syntax check (native macOS - FAST)
clang -m32 -fsyntax-only -I./usr/src/kernel/include \
    usr/src/kernel/kern/newfile.c

# 2. Full compilation (Docker + Rosetta - MODERATE)
docker run -it --rm --platform linux/amd64 \
    -v "$(pwd):/workspace" 386bsd-dev \
    bash -c "cd /workspace && make kernel"

# 3. Link and test (QEMU - SLOW, only when needed)
./boot-qemu.sh
```

### Build Script
Create a unified build script:

```bash
#!/bin/bash
# build.sh - Unified build script for M1

MODE="${1:-rosetta}"

case "$MODE" in
    native)
        echo "🚀 Building with native macOS toolchain..."
        clang -m32 -march=i386 -target i386-pc-none-elf \
            -ffreestanding -fno-builtin \
            -I./usr/src/kernel/include \
            -I./usr/src/kernel/include/sys \
            -I./usr/src/kernel \
            -DKERNEL -Di386 \
            usr/src/kernel/kern/*.c
        ;;

    rosetta)
        echo "🐋 Building with Docker + Rosetta 2..."
        docker run --rm --platform linux/amd64 \
            -v "$(pwd):/workspace" 386bsd-dev \
            bash -c "cd /workspace && make kernel"
        ;;

    test)
        echo "🖥️  Testing kernel in QEMU..."
        ./boot-qemu.sh
        ;;

    *)
        echo "Usage: $0 {native|rosetta|test}"
        exit 1
        ;;
esac
```

---

## 🎯 Quick Start

```bash
# 1. Install Colima (one-time setup)
brew install colima docker
colima start --arch x86_64 --vz-rosetta --cpu 4 --memory 8

# 2. Build Docker image
docker build -f .devcontainer/Dockerfile.rosetta -t 386bsd-dev .

# 3. Compile kernel
docker run -it --rm --platform linux/amd64 \
    -v "$(pwd):/workspace" 386bsd-dev \
    bash -c "cd /workspace/usr/src/kernel && make"

# 4. Test in QEMU (when ready)
qemu-system-i386 -kernel build/kernel.elf -m 128M
```

---

## 🐛 Troubleshooting

### "exec format error" in Docker
```bash
# Ensure Rosetta 2 is enabled
colima ls  # Check if --vz-rosetta is active

# Or enable in Docker Desktop settings
# Settings → Features in development → Use Rosetta
```

### Slow Docker builds
```bash
# Are you using Rosetta?
docker info | grep -i rosetta

# If not, use Colima instead of Docker Desktop
colima delete
colima start --arch x86_64 --vz-rosetta --cpu 4 --memory 8
```

### macOS native builds fail
```bash
# Install required tools
brew install gcc@13
brew install llvm

# Use explicit paths
/opt/homebrew/bin/gcc-13 -m32 ...
```

---

## 📚 Additional Resources

- **QEMU Performance**: https://www.qemu.org/docs/master/system/invocation.html
- **Rosetta 2 Details**: https://developer.apple.com/documentation/virtualization
- **Colima Documentation**: https://github.com/abiosoft/colima

---

## 🎓 Summary

**Best Practice Tiers:**

1. **Tier 1** (Daily Use): Docker + Rosetta 2 via Colima
2. **Tier 2** (Quick Checks): Native macOS cross-compile with clang
3. **Tier 3** (Final Testing): QEMU x86 full emulation

**Expected Build Times** (for full kernel):
- Native macOS: ~30 seconds
- Docker + Rosetta: ~45 seconds (85% of native)
- QEMU: ~5-10 minutes (avoid for builds)

Choose Docker + Rosetta 2 as your primary development environment for the best balance of speed, accuracy, and consistency.
