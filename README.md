# 386BSD

**386BSD** is the first open-source BSD operating system, created in the late 1980s by William and Lynne Jolitz. It blended the Unix® Version 6 heritage from AT&T/Bell Labs with Berkeley’s early BSD extensions, ported and extended for the Intel 80386.

---

## ⚙️ Project Overview

This repository houses the **original 386BSD source** and **prebuilt binaries**, reconstructed from decades-old tapes, floppies, and hard drives. Because of media degradation over time, some releases are incomplete or partially recovered. We’re actively working to fill gaps from multiple archival sources.

**Key features:**
- Self-hosting on 386 hardware (≤ 32 MB RAM)
- Compatible with modern emulators (QEMU, VirtualBox)
- Dual-licensing under the historic 386BSD license

🔗 [William Jolitz’s 386BSD Notebook](https://386bsd.github.io/) — deep dive into architectures, design notes, and usage tips.

---

## 📂 Repository Layout

.
├── bin/             ← Pre-built 386BSD binaries (snapshots)
├── doc/             ← Installation manuals & documentation
├── man/             ← Original *roff manual sources
├── misc/            ← Utility scripts & ancillary files
├── usr/src/         ← 386BSD userland and libraries
│   └── kernel/      ← 386BSD kernel sources
├── tests/           ← Test harness & CI scripts
├── build.sh         ← Multi-profile build orchestrator
├── Makefile         ← Top-level wrapper for historic makefiles
├── .gitignore       ← Ignore build artifacts & legacy outputs
└── LICENSE          ← Full text of the 386BSD license

---

## 🛠️ Prerequisites

To build **both** userland and kernel:

- **Host OS:** any Unix-like system (Linux, macOS, BSD)
- **Shell:** POSIX-compliant (`bash`, `zsh`, etc.)
- **C compiler:** GCC ≥ 2.7 or Clang (cross-compiler targeting i386 work well)
- **BSD make:** (`bmake` or `pmake`)
- **GNU binutils:** (`as`, `ld`, `ar`)
- **groff** (for formatting man pages)
- **Optional:** Python 3 (test harness), QEMU/VirtualBox (VM testing)

On Debian/Ubuntu, for example:
```sh
sudo apt-get update
sudo apt-get install -y build-essential bmake groff python3 qemu-system-x86


⸻

🏗️ Building

1. Single-script build

# Developer build (with debug symbols & warnings)
./build.sh

# Performance-optimized build
./build.sh -p performance

# Release build (stripped; -O2)
./build.sh -p release

Each profile sets CC and CFLAGS appropriately. Inspect build.sh for exact flags.

⸻

2. Manual build via Makefile

The top-level Makefile will recurse into usr/src and usr/src/kernel:

# Build everything
make

# Override compiler/flags:
make CC=clang CFLAGS="-O2 -pipe -std=c11"

# Clean all subdirectories
make clean


⸻

🚀 Installing & Running
	1.	Install (optional):

cd usr/src
bmake install DESTDIR=/some/path


	2.	Boot in QEMU:

qemu-system-i386 \
  -kernel usr/src/kernel/kernel \
  -hda fs.img \
  -m 16M \
  -nographic


	3.	On real hardware: write kernel and fs.img to floppy or hard disk as per doc/install.ms.

Refer to doc/install.ms (format with nroff -ms doc/install.ms | less) for full installation steps.

⸻

🌿 Branch Overview
	•	0.1 — Initial public snapshot; self-hosting on small-memory 386 systems.
	•	1.0 — More complete set of utilities, drivers, and system calls.
	•	2.0 — Reconstruction in progress; partial sources and binaries.
	•	main — Our current “working” branch, merging recoveries across all archives.

Watch for feature branches (e.g. .x) as we digitize additional boxes of notes and floppies.

⸻

📜 License

This project is distributed under the 386BSD License. See LICENSE for the full text.

The Regents of the University of California and contributors “AS IS” disclaimer applies.

⸻

🔗 Further Reading
	•	Official notebook: https://386bsd.github.io/
	•	Original distribution tape README: reproduced in doc/legacy/READ_ME
	•	BSD networking history: see misc/arp, misc/ifconfig sources

⸻

© 1989–1992 William and Lynne Jolitz. All rights reserved.

