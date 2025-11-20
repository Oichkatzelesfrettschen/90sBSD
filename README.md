# 386BSD

**386BSD** is the first open-source BSD operating system, created in the late 1980s by William and Lynne Jolitz. It combines the Unix® Version 6 heritage from AT&T/Bell Labs with Berkeley’s early BSD extensions, ported and extended for the Intel 80386.

This repository is a modernization project, aiming to bring this historical codebase to C17 and POSIX.1-2017 compliance, while retaining its original spirit.

---

## 📖 Project Documentation

For a comprehensive understanding of the project's architecture, modernization roadmap, and historical context, please consult our detailed documentation:

**[➡️ Explore the Full Documentation](./docs/README.md)**

---

## 🚀 Quick Start

### 1. Installation (Ubuntu 24.04)

All required tools are available in the official Ubuntu 24.04 repositories.

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
```
For other operating systems and more detailed instructions, see the [full installation guide](./TOOL_INSTALLATION_GUIDE.md).

### 2. Automated Setup & Sanity Check

After installing the dependencies, you can use the `build-troubleshoot.sh` script to verify your setup.

```bash
# Clone the repository
git clone https://github.com/Oichkatzelesfrettschen/386bsd.git
cd 386bsd

# Test your setup
./scripts/build-troubleshoot.sh --full-check
```

### 3. Build the System

This project supports both a modern CMake-based build system and the original legacy Makefiles.

**Modern Development (Recommended)**:
```bash
mkdir build && cd build
cmake .. -DBUILD_DOCS=ON -DBUILD_TESTS=ON
make -j$(nproc)
```

**Legacy Compatibility**:
```bash
cd usr/src
bmake clean
bmake -n  # dry run
```

> **Having build issues?** See our [Troubleshooting Guide](./docs/build/BUILD_ISSUES.md).

---

## 📂 Repository Layout

.
├── bin/               ← Pre-built 386BSD binaries (snapshots)
├── docs/              ← **(Start Here)** Comprehensive project documentation
├── usr/src/           ← 386BSD userland and kernel sources
├── tests/             ← Test harness & CI scripts
├── scripts/           ← Helper scripts for modernization and builds
├── boot/              ← Bootloader and kernel images
└── ... and more

---

##  CONTRIBUTING

Contributions are welcome! If you're looking for a place to start, we have a detailed report of known issues and areas for improvement in the codebase.

*   **[CODE_MARKERS_REPORT.md](./CODE_MARKERS_REPORT.md)**: A comprehensive analysis of `TODO`, `FIXME`, `HACK`, and `XXX` comments in the source, with a prioritized roadmap for fixing them.
*   **[CODE_MARKERS_QUICK_START.txt](./CODE_MARKERS_QUICK_START.txt)**: A summary of the most critical issues from the code markers report.

---

## 📜 License

This project is distributed under the 386BSD License. See `LICENSE` for the full text.

© 1989–1992 William and Lynne Jolitz. All rights reserved.
