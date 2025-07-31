# 386BSD

386BSD is the first open-source BSD operating system, created by [William](https://www.linkedin.com/in/williamjolitz/) and Lynne Jolitz.

[William Jolitz's 386bsd Notebook](https://386bsd.github.io/)

All releases are currently inconsistent due to media failures and undated partial copies that I am able to extract from drives, tapes, and floppies.

We are working through boxes of decades-old notes. Releases 0.1 and 1.0 are self-compiling on small memory systems (<32 MB) and run well in virtual machines such as QEMU or VirtualBox.

The branch history is idiosyncratic: 0.1 and 1.0 are the most useful at the moment, while 2.0 has the most gaps.

After everything is sorted out, look for a ".x" branch for future development (from a second box!).

William Jolitz.

## Build prerequisites

386BSD relies on the classic BSD toolchain. You will need:

- A 386-compatible system or emulator.
- An ANSI C compiler. Historical releases built with GCC 2.5.8 or 2.7.2 in combination with GNU binutils.
- BSD `make` (often packaged as `pmake` or `bmake`).

Modern hosts can build the system using the `bmake` utility and an old GCC
toolchain. A cross‐compiler configured for 386 targets works well when the
historic compilers are not available.

## Building the system

1. Change to the source tree:
   ```
   cd usr/src
   ```
2. Build userland and libraries with BSD make:
   ```
   bmake
   ```
3. Optionally install the results:
   ```
   bmake install
   ```

To build the kernel, run `bmake` in `usr/src/kernel`.

## Branch overview

* `0.1` – initial public snapshot supporting self-hosted builds on small-memory systems.
* `1.0` – more complete system with many utilities and drivers integrated.
* `2.0` – work-in-progress development branch currently being reconstructed.

## Further documentation

For advanced setup topics such as running 386BSD under QEMU or other
virtualization environments, consult [William Jolitz's 386bsd Notebook](https://386bsd.github.io/).
