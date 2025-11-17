# 386BSD Modernization & QEMU Boot Roadmap

**Project Goal**: Import from 4.4BSD, 4.4BSD Lite2, 4.3BSD, and NetBSD repositories to build a complete, bootable 386BSD system running on QEMU i386 with modern compiler support.

**Status**: Phase 1-4 Complete | Current: Phase 5 Planning
**Last Updated**: 2025-11-17

---

## Executive Summary

The 386BSD repository has successfully completed 4 phases of modernization:
- ✅ Core build system repair (35+ object files compiling)
- ✅ CI/CD pipeline stabilization
- ✅ Deep OS integration (assembly syntax, headers, C fixes)
- ✅ Advanced build orchestration

**Next Goal**: Import missing components from other BSD variants and create a fully bootable system in QEMU.

---

## 📊 Current State Analysis

### What We Have ✅
- **Kernel**: 42 subsystems, ~5.2 MB source, 526 files
- **Libraries**: Complete libc (290 functions), libm, libcurses, libg++
- **Userland**: 900+ utilities (sh, gcc, gdb, networking tools)
- **Build System**: Working BMake + CMake, Clang 18.1.3 toolchain
- **Compilation**: 35+ kernel objects compiling successfully

### What's Missing ❌
- **Complete Kernel Build**: Full kernel link not yet tested
- **Bootloader**: Needs modernization for QEMU/UEFI
- **Modern Drivers**: USB, SATA, modern network cards
- **Dynamic Linking**: Shared library support incomplete
- **QEMU Testing**: Boot chain untested

### Import Sources Identified

| Source Repository | Purpose | Priority |
|------------------|---------|----------|
| **sergev/4.4BSD-Lite2** | Complete system reference, modern drivers | HIGH |
| **dank101/4.4BSD-Lite2** | Alternative complete source | MEDIUM |
| **NetBSD current** | Modern i386 support, QEMU PVH boot | HIGH |
| **FreeBSD 5.x** | PCI drivers, modern hardware support | MEDIUM |
| **OpenBSD** | Security features, USB support | LOW |

---

## 🎯 Phase 5: Complete Kernel Build & Link

**Goal**: Successfully compile and link a complete 386BSD kernel binary

### Tasks

#### 5.1 Kernel Compilation Analysis
- [ ] Audit all 42 kernel subsystems for completeness
- [ ] Identify remaining compilation errors
- [ ] Create dependency graph for kernel modules
- [ ] Document missing source files

#### 5.2 Import Missing Kernel Components
**From 4.4BSD-Lite2 (sergev/4.4BSD-Lite2)**:
- [ ] Clone repository: `git clone https://github.com/sergev/4.4BSD-Lite2.git`
- [ ] Extract missing kernel sources from `usr/src/sys/`
- [ ] Import missing device drivers
- [ ] Import missing system calls
- [ ] Import missing header files

**Specific Imports Needed**:
```bash
# Device drivers
4.4BSD-Lite2/usr/src/sys/i386/isa/      → usr/src/kernel/isa/
4.4BSD-Lite2/usr/src/sys/i386/include/  → usr/src/kernel/i386/include/
4.4BSD-Lite2/usr/src/sys/kern/          → usr/src/kernel/kern/ (missing files)

# System calls
4.4BSD-Lite2/usr/src/sys/kern/syscalls.master → usr/src/kernel/kern/
```

#### 5.3 Kernel Link Configuration
- [ ] Create proper linker script for i386 ELF kernel
- [ ] Configure kernel entry point and memory layout
- [ ] Set up symbol table for debugging
- [ ] Test kernel linking with `ld.lld`

#### 5.4 Validation
- [ ] Ensure all kernel modules compile
- [ ] Successfully link complete kernel binary
- [ ] Verify kernel size and structure
- [ ] Extract and validate symbol table

**Expected Output**: `usr/src/kernel/386bsd` (bootable kernel binary)

**Duration**: 2-3 days
**Complexity**: HIGH

---

## 🎯 Phase 6: Bootloader Modernization

**Goal**: Create/update bootloader to boot 386BSD kernel in QEMU

### Tasks

#### 6.1 Analyze Existing Bootloader
- [ ] Examine `bootstrap/boot` directory
- [ ] Understand boot sequence and requirements
- [ ] Identify BIOS vs. UEFI capabilities
- [ ] Document boot protocol

#### 6.2 Import Bootloader Components
**From 4.4BSD-Lite2**:
- [ ] Extract `usr/src/sys/i386/boot/` directory
- [ ] Import boot blocks and boot2 code
- [ ] Import master boot record (MBR) code

**From NetBSD**:
- [ ] Import modern PVH boot support for QEMU
- [ ] Import multiboot support
- [ ] Import GRUB compatibility layer

#### 6.3 Bootloader Compilation
- [ ] Set up standalone boot environment (no libc)
- [ ] Compile boot blocks with `-ffreestanding`
- [ ] Create boot.cfg configuration
- [ ] Test bootloader size constraints (must fit in 512 bytes for stage 1)

#### 6.4 Integration
- [ ] Create bootable disk image structure
- [ ] Install bootloader to MBR
- [ ] Configure kernel load parameters
- [ ] Test with QEMU

**Expected Output**: Working bootloader that loads 386bsd kernel

**Duration**: 3-4 days
**Complexity**: VERY HIGH

---

## 🎯 Phase 7: QEMU Environment Setup

**Goal**: Configure QEMU i386 environment for 386BSD

### Tasks

#### 7.1 Install QEMU
```bash
sudo apt-get install -y qemu-system-x86 qemu-utils
```

#### 7.2 Create Virtual Disk Image
```bash
# Create 512MB disk image
qemu-img create -f qcow2 386bsd-disk.qcow2 512M

# Format and partition
fdisk 386bsd-disk.qcow2
# Create UFS filesystem
```

#### 7.3 QEMU Configuration
**Optimal QEMU flags for 386BSD**:
```bash
qemu-system-i386 \
  -M pc \
  -cpu 486 \
  -m 64M \
  -kernel usr/src/kernel/386bsd \
  -hda 386bsd-disk.qcow2 \
  -serial stdio \
  -nographic \
  -append "root=/dev/hda1 console=ttyS0"
```

#### 7.4 Import NetBSD QEMU Support
**From NetBSD**:
- [ ] Import microvm kernel configuration
- [ ] Import PVH boot support
- [ ] Import virtio drivers for better performance

**Benefits**:
- Faster boot times
- Better performance
- Modern paravirtualization

#### 7.5 Testing Script
- [ ] Create automated boot test script
- [ ] Add boot success detection
- [ ] Configure serial console logging
- [ ] Add screenshot capture

**Expected Output**: QEMU environment that boots 386BSD kernel

**Duration**: 1-2 days
**Complexity**: MEDIUM

---

## 🎯 Phase 8: Root Filesystem Creation

**Goal**: Build complete userland and create bootable root filesystem

### Tasks

#### 8.1 Userland Compilation
```bash
cd usr/src
bmake cleandir
bmake obj
bmake depend
bmake all
```

#### 8.2 Import Missing Userland Components
**From 4.4BSD-Lite2**:
- [ ] Import missing utilities: `usr/src/bin/`, `usr/src/sbin/`
- [ ] Import init system: `usr/src/sbin/init/`
- [ ] Import essential daemons
- [ ] Import shell (sh, csh)

**Essential Programs**:
- init, login, getty
- sh, ls, cat, cp, mv, rm
- mount, fsck, shutdown, reboot
- ifconfig, route, ping

#### 8.3 Create Filesystem Layout
```bash
# Standard BSD layout
/bin        # Essential binaries
/sbin       # System binaries
/etc        # Configuration files
/dev        # Device nodes
/lib        # Shared libraries
/usr        # User programs and data
/var        # Variable data
/tmp        # Temporary files
/home       # User home directories
/root       # Root user home
```

#### 8.4 Install to Disk Image
```bash
# Mount disk image
mkdir /mnt/386bsd
mount -o loop 386bsd-disk.qcow2 /mnt/386bsd

# Install system
cd usr/src
bmake install DESTDIR=/mnt/386bsd

# Create device nodes
cd /mnt/386bsd/dev
./MAKEDEV all
```

#### 8.5 Configuration Files
**Import from 4.4BSD-Lite2**:
- [ ] `/etc/rc` - Startup script
- [ ] `/etc/fstab` - Filesystem table
- [ ] `/etc/ttys` - Terminal configuration
- [ ] `/etc/hosts`, `/etc/resolv.conf` - Network config

**Expected Output**: Complete bootable root filesystem

**Duration**: 2-3 days
**Complexity**: MEDIUM

---

## 🎯 Phase 9: Modern Compiler Compatibility

**Goal**: Ensure all code compiles with Clang 18+ and modern GCC

### Tasks

#### 9.1 C Standard Compliance
- [ ] Audit code for K&R C vs. ANSI C issues
- [ ] Fix implicit function declarations
- [ ] Add function prototypes where missing
- [ ] Fix type mismatches

#### 9.2 Import Modern BSD Headers
**From NetBSD current**:
- [ ] Import modernized system headers
- [ ] Import POSIX compliance headers
- [ ] Import C99/C11 compatibility headers

#### 9.3 Compiler Warning Fixes
```bash
# Enable strict warnings
CFLAGS="-Wall -Wextra -Werror -pedantic"

# Common fixes needed:
# - Implicit function declarations
# - Type mismatches (int vs. long)
# - Pointer signedness
# - Format string mismatches
# - Unused variables
```

#### 9.4 GCC-isms Removal
- [ ] Replace GCC-specific extensions
- [ ] Use standard C features instead
- [ ] Add conditional compilation for extensions
- [ ] Test with both Clang and GCC

#### 9.5 Cross-Compilation Setup
```bash
# 32-bit compilation on 64-bit host
CC="clang -m32"
CFLAGS="-march=i386 -m32 -ffreestanding"
LDFLAGS="-m elf_i386"
```

**Expected Output**: 100% clean compilation with modern compilers

**Duration**: 3-4 days
**Complexity**: HIGH

---

## 🎯 Phase 10: Device Driver Modernization

**Goal**: Add modern hardware support for QEMU and real hardware

### Tasks

#### 10.1 Import Essential Drivers
**From FreeBSD 5.x**:
- [ ] PCI bus support (`sys/dev/pci/`)
- [ ] Modern network cards (Intel e1000, Realtek 8139)
- [ ] AHCI SATA controller
- [ ] USB 1.1/2.0 support

**From NetBSD**:
- [ ] Virtio drivers (virtio-blk, virtio-net, virtio-balloon)
- [ ] Modern console drivers
- [ ] PCI-Express support

#### 10.2 Driver Adaptation
- [ ] Port drivers to 386BSD kernel API
- [ ] Update for modern kernel interfaces
- [ ] Add proper locking and synchronization
- [ ] Test in QEMU environment

#### 10.3 Virtio Integration (QEMU Performance)
```c
// Import from NetBSD
virtio/
  ├── virtio.c           // Core virtio bus
  ├── virtio_pci.c       // PCI transport
  ├── virtio_blk.c       // Block device
  ├── virtio_net.c       // Network device
  └── virtio_balloon.c   // Memory balloon
```

**Benefits**:
- 10-50x faster I/O in QEMU
- Better network performance
- Dynamic memory management

#### 10.4 Legacy Driver Cleanup
- [ ] Remove obsolete ISA-only drivers
- [ ] Update DMA handling for modern systems
- [ ] Fix interrupt handling
- [ ] Update for APIC vs. PIC

**Expected Output**: Modern hardware support in kernel

**Duration**: 5-7 days
**Complexity**: VERY HIGH

---

## 🎯 Phase 11: Dynamic Linking & Shared Libraries

**Goal**: Implement shared library support for smaller binaries

### Tasks

#### 11.1 Import Dynamic Linker
**From 4.4BSD-Lite2**:
- [ ] Import `ld.so` dynamic linker
- [ ] Import `rtld` runtime linker
- [ ] Import ELF loader support

#### 11.2 Convert Static Libraries to Shared
```bash
# Convert libc to shared library
cd usr/src/lib/libc
bmake clean
bmake SHLIB_MAJOR=2 SHLIB_MINOR=0
# Creates libc.so.2.0
```

**Libraries to Convert**:
- libc.so (highest priority)
- libm.so
- libcurses.so
- libutil.so

#### 11.3 Update Kernel Support
- [ ] Implement shared library syscalls
- [ ] Add ELF shared object loading
- [ ] Implement position-independent code (PIC) support
- [ ] Add symbol resolution

#### 11.4 Update Build System
- [ ] Modify makefiles for shared library builds
- [ ] Add `-fPIC` flag for position-independent code
- [ ] Update linker flags for dynamic linking
- [ ] Create library versioning system

**Expected Output**: Working dynamic linking system

**Duration**: 4-5 days
**Complexity**: VERY HIGH

---

## 🎯 Phase 12: Testing & Validation

**Goal**: Comprehensive testing of the complete system

### Tasks

#### 12.1 Boot Testing
```bash
# Automated boot test
./tests/boot-test.sh

# Expected output:
# - Bootloader loads successfully
# - Kernel boots and mounts root
# - Init starts
# - Getty spawns on console
# - Login prompt appears
```

#### 12.2 Functionality Testing
- [ ] Test all core utilities
- [ ] Test file operations
- [ ] Test networking (ping, telnet, ftp)
- [ ] Test process management
- [ ] Test IPC mechanisms

#### 12.3 Performance Testing
- [ ] Benchmark disk I/O
- [ ] Benchmark network throughput
- [ ] Benchmark compilation speed
- [ ] Measure boot time

#### 12.4 Stress Testing
- [ ] Memory stress test
- [ ] Disk stress test
- [ ] Network stress test
- [ ] Concurrent process test

#### 12.5 Compatibility Testing
- [ ] Test on different QEMU versions
- [ ] Test on real hardware (if available)
- [ ] Test with different memory sizes
- [ ] Test with different CPU models

**Expected Output**: Stable, tested system

**Duration**: 3-4 days
**Complexity**: MEDIUM

---

## 🎯 Phase 13: Documentation & Polish

**Goal**: Complete documentation and user guides

### Tasks

#### 13.1 User Documentation
- [ ] Installation guide
- [ ] Boot process documentation
- [ ] Configuration guide
- [ ] Troubleshooting guide

#### 13.2 Developer Documentation
- [ ] Build system documentation
- [ ] Kernel architecture guide
- [ ] Driver development guide
- [ ] Contribution guidelines

#### 13.3 Create Prebuilt Images
- [ ] Build release kernel
- [ ] Create bootable ISO image
- [ ] Create QEMU disk image
- [ ] Create VirtualBox image

#### 13.4 Automation Scripts
```bash
# One-command boot
./boot-386bsd.sh

# One-command build
./build-all.sh

# One-command test
./test-all.sh
```

**Expected Output**: Professional, documented system

**Duration**: 2-3 days
**Complexity**: LOW

---

## 📋 Detailed Import Strategy

### Source Repository Matrix

| Component | Source Repo | Path | Priority |
|-----------|------------|------|----------|
| **Kernel Sources** | sergev/4.4BSD-Lite2 | `usr/src/sys/` | P0 |
| **Bootloader** | sergev/4.4BSD-Lite2 | `usr/src/sys/i386/boot/` | P0 |
| **Init System** | sergev/4.4BSD-Lite2 | `usr/src/sbin/init/` | P0 |
| **Core Utilities** | sergev/4.4BSD-Lite2 | `usr/src/bin/`, `usr/src/sbin/` | P0 |
| **Libc** | sergev/4.4BSD-Lite2 | `usr/src/lib/libc/` | P1 |
| **Dynamic Linker** | sergev/4.4BSD-Lite2 | `usr/src/libexec/ld.so/` | P1 |
| **Virtio Drivers** | NetBSD | `sys/dev/virtio/` | P1 |
| **PVH Boot** | NetBSD | `sys/arch/i386/stand/` | P1 |
| **Modern PCI** | FreeBSD 5.x | `sys/dev/pci/` | P2 |
| **USB Support** | OpenBSD | `sys/dev/usb/` | P2 |
| **Security Features** | OpenBSD | `sys/kern/` | P3 |

### Import Procedure

```bash
# 1. Clone source repositories
mkdir -p ../bsd-sources
cd ../bsd-sources

git clone https://github.com/sergev/4.4BSD-Lite2.git
git clone https://github.com/NetBSD/src.git netbsd
git clone https://github.com/freebsd/freebsd-src.git freebsd

# 2. Create import scripts
cd ../386bsd
cat > scripts/import-from-bsd.sh << 'EOF'
#!/bin/bash
# Import helper script
SOURCE_REPO=$1
SOURCE_PATH=$2
DEST_PATH=$3

# Validate and copy with history preservation
rsync -av --progress "$SOURCE_REPO/$SOURCE_PATH" "$DEST_PATH"

# Update copyright headers
find "$DEST_PATH" -type f -exec sed -i '1i\/* Imported from BSD sources */' {} \;

# Track import
echo "$(date): Imported $SOURCE_PATH from $SOURCE_REPO" >> IMPORT_LOG.txt
EOF

chmod +x scripts/import-from-bsd.sh

# 3. Execute imports (example)
./scripts/import-from-bsd.sh ../bsd-sources/4.4BSD-Lite2 \
  usr/src/sys/i386/boot \
  usr/src/bootstrap

# 4. Adapt and integrate
# - Fix header paths
# - Update Makefiles
# - Resolve conflicts
# - Test compilation
```

---

## 🛠 Tool Installation Plan

### System Requirements

```bash
# Ubuntu 24.04 complete toolchain
sudo apt-get update
sudo apt-get install -y \
  build-essential \
  bmake \
  cmake \
  ninja-build \
  clang \
  clang-tools \
  lld \
  llvm \
  gcc-multilib \
  libc6-dev-i386 \
  qemu-system-x86 \
  qemu-utils \
  flex \
  bison \
  groff \
  doxygen \
  graphviz \
  python3 \
  python3-pip \
  git \
  rsync \
  curl \
  wget

# Python documentation tools
pip3 install --user sphinx breathe sphinx-rtd-theme
```

### Cross-Compilation Toolchain

```bash
# Clang for i386 cross-compilation
export CC="clang"
export CXX="clang++"
export AS="clang"
export LD="ld.lld"
export AR="llvm-ar"
export RANLIB="llvm-ranlib"
export OBJCOPY="llvm-objcopy"
export STRIP="llvm-strip"

# Target flags
export CFLAGS="-target i386-unknown-elf -m32 -march=i386 -ffreestanding -fno-builtin -fno-stack-protector"
export LDFLAGS="-m elf_i386"
```

---

## 📅 Timeline & Milestones

### Overall Timeline: 4-6 weeks

| Phase | Duration | Start | End | Milestone |
|-------|----------|-------|-----|-----------|
| Phase 5: Complete Kernel Build | 3 days | Day 1 | Day 3 | Linked kernel binary |
| Phase 6: Bootloader | 4 days | Day 4 | Day 7 | Working bootloader |
| Phase 7: QEMU Setup | 2 days | Day 8 | Day 9 | QEMU boots kernel |
| Phase 8: Root Filesystem | 3 days | Day 10 | Day 12 | Complete userland |
| Phase 9: Compiler Compat | 4 days | Day 13 | Day 16 | Clean compilation |
| Phase 10: Drivers | 7 days | Day 17 | Day 23 | Modern hardware |
| Phase 11: Dynamic Linking | 5 days | Day 24 | Day 28 | Shared libraries |
| Phase 12: Testing | 4 days | Day 29 | Day 32 | Validated system |
| Phase 13: Documentation | 3 days | Day 33 | Day 35 | Release ready |

### Critical Path
1. **Phase 5** (kernel build) → **Phase 6** (bootloader) → **Phase 7** (QEMU) = First boot
2. **Phase 8** (userland) → **Phase 12** (testing) = Usable system
3. **Phase 10** (drivers) → Modern hardware support

### Minimum Viable Product (MVP)
- **Week 2**: Kernel boots in QEMU with basic console
- **Week 4**: Full userland boots to login prompt
- **Week 6**: Complete system with modern features

---

## 🎯 Success Criteria

### Phase 5-7 Success (First Boot)
- [ ] Kernel binary links successfully
- [ ] Bootloader loads kernel
- [ ] Kernel boots in QEMU
- [ ] Console output visible
- [ ] No kernel panics

### Phase 8-9 Success (Usable System)
- [ ] Init starts successfully
- [ ] Login prompt appears
- [ ] Shell (sh) works
- [ ] Basic utilities functional
- [ ] Filesystem operations work

### Phase 10-13 Success (Modern System)
- [ ] Virtio drivers work
- [ ] Network functional
- [ ] Dynamic linking works
- [ ] All tests pass
- [ ] Performance acceptable

### Final Success Criteria
- ✅ **Boots in QEMU i386** without errors
- ✅ **Compiles with Clang 18+** and GCC 13+
- ✅ **Complete userland** with all essential tools
- ✅ **Modern hardware support** via virtio
- ✅ **Dynamic linking** functional
- ✅ **Self-hosting capable** (can compile itself)
- ✅ **Documented and tested**

---

## 🚨 Risk Assessment

### High Risk Items

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Kernel linking failures | HIGH | MEDIUM | Import linker scripts from 4.4BSD-Lite2 |
| Bootloader complexity | HIGH | HIGH | Use proven NetBSD PVH boot |
| License incompatibility | MEDIUM | LOW | Verify all imports are BSD-licensed |
| Hardware support issues | MEDIUM | MEDIUM | Focus on QEMU virtio first |
| Build system conflicts | LOW | MEDIUM | Careful makefile integration |

### Contingency Plans

**If kernel won't link**:
- Fall back to static kernel image from 4.4BSD-Lite2
- Use GRUB multiboot instead of custom bootloader

**If bootloader too complex**:
- Use GRUB2 as bootloader
- Focus on kernel quality over custom boot

**If QEMU won't boot**:
- Try different QEMU machine types (-M pc, -M isapc)
- Use older QEMU version known to work with BSD

**If driver porting fails**:
- Start with minimal driver set (console + disk only)
- Add drivers incrementally

---

## 📚 Resources & References

### BSD Source Repositories
- **4.4BSD-Lite2**: https://github.com/sergev/4.4BSD-Lite2
- **NetBSD**: https://github.com/NetBSD/src
- **FreeBSD**: https://github.com/freebsd/freebsd-src
- **OpenBSD**: https://github.com/openbsd/src

### Documentation
- **4.4BSD Documentation**: https://www.netbsd.org/docs/bsd/
- **NetBSD QEMU Guide**: https://wiki.netbsd.org/ports/i386/
- **QEMU i386 Docs**: https://www.qemu.org/docs/master/system/target-i386.html
- **BSD Boot Process**: https://docs.freebsd.org/en/books/arch-handbook/boot/

### Technical References
- **ELF Specification**: https://refspecs.linuxfoundation.org/elf/elf.pdf
- **i386 ABI**: https://www.uclibc.org/docs/psABI-i386.pdf
- **Virtio Spec**: https://docs.oasis-open.org/virtio/virtio/v1.1/virtio-v1.1.html
- **Multiboot Spec**: https://www.gnu.org/software/grub/manual/multiboot/multiboot.html

---

## 🎬 Getting Started

### Immediate Next Steps (Day 1)

1. **Install missing tools**:
```bash
sudo apt-get install -y bmake qemu-system-x86 qemu-utils flex groff
```

2. **Clone BSD source repositories**:
```bash
mkdir -p ../bsd-sources && cd ../bsd-sources
git clone https://github.com/sergev/4.4BSD-Lite2.git
git clone --depth 1 https://github.com/NetBSD/src.git netbsd
cd ../386bsd
```

3. **Test current kernel build**:
```bash
cd usr/src/kernel
bmake clean
bmake depend
bmake all 2>&1 | tee ../../build.log
```

4. **Analyze build failures**:
```bash
grep -i "error:" ../../build.log | sort | uniq
```

5. **Begin Phase 5 imports**:
```bash
# Create import directory
mkdir -p imports/4.4bsd-lite2
# Start documenting what's needed
```

### First Week Goals
- Complete Phase 5 (kernel build)
- Start Phase 6 (bootloader)
- Have first QEMU boot attempt

---

## 📞 Support & Community

### Getting Help
- **GitHub Issues**: Report problems and track progress
- **Build Logs**: Save to `build-logs/` directory
- **Import Tracking**: Use `IMPORT_LOG.txt`

### Contributing
- Document all imports with source attribution
- Maintain BSD license compliance
- Test all changes in QEMU before committing
- Update this roadmap as progress is made

---

**Last Updated**: 2025-11-17
**Status**: Ready to begin Phase 5
**Next Milestone**: Complete kernel binary (Day 3)

---

## Appendix A: Command Reference

### Quick Commands
```bash
# Install all dependencies
./scripts/build-troubleshoot.sh --install-deps

# Build kernel
cd usr/src/kernel && bmake clean depend all

# Boot in QEMU
qemu-system-i386 -kernel kernel/386bsd -m 64M -nographic

# Import from BSD source
./scripts/import-from-bsd.sh <source> <src-path> <dest-path>

# Run tests
./scripts/build-orchestrator.sh test

# Create bootable image
./scripts/create-image.sh
```

### Build Troubleshooting
```bash
# Check dependencies
bmake -n

# Verbose build
bmake -d A

# Single file compilation
clang -c -m32 -I../include file.c -o file.o

# Check symbols
nm -g kernel/386bsd | less
```

---

**End of Roadmap**
