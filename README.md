# 386BSD

**386BSD** is the first open-source BSD operating system, created in the late 1980s by William and Lynne Jolitz. It combines the Unix® Version 6 heritage from AT&T/Bell Labs with Berkeley’s early BSD extensions, ported and extended for the Intel 80386.

---

## 📖 Project Overview

This repository contains:

- **Original 386BSD source** and **prebuilt binaries**, reconstructed from decades-old tapes, floppies, and hard drives.
- A reproducible, multi-profile build system (`build.sh` + `Makefile`).
- Tools and scripts to modernize symlinks, format man pages, run tests, and boot under QEMU.

> **Note:** Some releases are incomplete due to media degradation; we’re actively merging recoveries from multiple archives.

---

## 📂 Repository Layout

.
├── bin/               ← Pre-built 386BSD binaries (snapshots)
├── doc/               ← Installation & configuration manuals
│   └── legacy/        ← Original 2BSD/Unix-V6 troff sources
├── man/               ← *roff manual page sources
├── misc/              ← Utility scripts & ancillary files
├── usr/src/           ← 386BSD userland and libraries
│   └── kernel/        ← 386BSD kernel sources
├── tests/             ← Test harness & CI scripts
├── build.sh           ← Multi-profile build orchestrator
├── Makefile           ← Top-level wrapper for historical makefiles
├── scripts/           ← Helper scripts (e.g. relativize_symlinks.py)
├── .gitignore         ← Ignore build artifacts & legacy outputs
└── LICENSE            ← Full text of the historic 386BSD license

---

## ⚙️ Prerequisites

On a **Unix-like** host (Linux, macOS, BSD), install:

- **Shell:** POSIX-compliant (`bash`, `zsh`, …)  
- **C toolchain:**  
  - Compiler: GCC ≥ 2.7 or Clang (cross-compiler targeting i386 works best)  
  - Binutils: `as`, `ld`, `ar`  
- **BSD make:** (`bmake` or `pmake`)  
- **groff:** for formatting man pages (`nroff -ms`)  
- **Optional:**  
  - Python 3 (test harness, symlink helper)  
  - QEMU/VirtualBox (VM testing)

**Debian/Ubuntu example:**
```sh
sudo apt-get update
sudo apt-get install -y build-essential bmake groff python3 qemu-system-x86


⸻

🏗️ Building

1️⃣ Single-script build

A convenience wrapper that descends into each subdirectory’s historic Makefile:

# Developer build (with debug symbols & warnings)
./build.sh

# High-performance build (optimized)
./build.sh -p performance

# Release build (stripped, -O2)
./build.sh -p release

Profiles adjust CC, CFLAGS, and other flags. See build.sh for details.

⸻

2️⃣ Manual build via Makefile

If you prefer to invoke make directly:

# Build everything (userland + kernel)
make

# Override compiler and flags:
make CC=clang CFLAGS="-O2 -pipe -std=c11"

# Clean all subdirectories
make clean


⸻

🚀 Installation & Running
	1.	(Optional) Install userland & libraries:

cd usr/src
bmake install DESTDIR=/your/install/path


	2.	Boot under QEMU:

qemu-system-i386 \
  -kernel usr/src/kernel/kernel \
  -hda fs.img \
  -m 16M \
  -nographic


	3.	On real hardware:
Write kernel and fs.img to your floppy or hard disk as per doc/install.ms:

nroff -ms doc/install.ms | less



⸻

🔗 Symbolic Links

Original absolute symlinks have been rewritten to point into placeholder/. To regenerate them:

python3 scripts/relativize_symlinks.py

To list all symlinks:

git ls-files -s | awk '$1 == "120000" {print $4 " -> " $3}'
find . -type l -print

Refer to placeholder/README.md for external targets.

⸻

🌿 Branch Overview
	•	0.1 — Initial public snapshot; self-hosting on ≤ 32 MB 386 systems.
	•	1.0 — More complete utilities, drivers, and system calls.
	•	2.0 — Work-in-progress reconstruction; partial sources/binaries.
	•	main — Current “working” branch, merging across all archives.
	•	Future: watch for .x feature branches as new archives are digitized.

⸻

📜 License

This project is distributed under the 386BSD License.
See LICENSE for the full text, including the “AS IS” disclaimer.

⸻

📚 Further Reading
	•	🔗 William Jolitz’s 386BSD Notebook — architecture, design notes & tips
	•	📜 Original distribution README: doc/legacy/READ_ME
	•	🌐 BSD networking history: sources in misc/arp, misc/ifconfig

⸻

© 1989–1992 William and Lynne Jolitz. All rights reserved.