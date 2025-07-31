# Building 386BSD

This guide describes the toolchain and environment setup required to build the historic 386BSD source tree. The original build system assumes a UNIX host running an ANSI C compiler and traditional BSD make.

## Required toolchain

The original 386BSD sources expect a full BSD toolchain and related utilities.
On a modern Debian/Ubuntu system the following packages provide reasonably
compatible tools:

```sh
sudo apt-get install build-essential bmake bsdextrautils bcc libbsd-dev groff
```

These packages supply an ANSI C compiler, linker, assembler, the BSD `make`
utility, and the classic ``bcc`` 16‑bit compiler used by a few boot utilities.
Additional tools such as `bison` or `flex` may be desirable for optional
components. `groff` provides the `nroff` command used when formatting man
pages during the build (for example the `echo` utility installs `echo.1`).

## Environment variables

Set the following variables to control the build. Values shown are typical defaults:

```sh
export CC=gcc          # C compiler
export CFLAGS="-O2 -march=i386"  # Optimized flags
export MAKE=bmake      # BSD-style make
export DESTDIR=/tmp/386bsd-root    # Installation prefix
export NROFF=nroff    # Used to format manual pages
```

Adjust `DESTDIR` as needed if you want to install to a staging directory.

## Step-by-step build

1. **Fetch the source**
   ```sh
   git clone https://github.com/386bsd/386bsd.git
   cd 386bsd
   ```
2. **Configure the kernel**
   ```sh
   cd usr/src/kernel
   ${MAKE} config             # Generates headers for your host
   ```
3. **Build the system**
   ```sh
   cd ../../..
   ${MAKE} world              # Builds userland and kernel
   ```
4. **Install**
   ```sh
   ${MAKE} install DESTDIR=${DESTDIR}
   ```
5. **Test a userland build**
   ```sh
   cd usr/src/bin/echo
   ${MAKE}                    # should compile `echo` using bmake
   ./echo hello               # verify the resulting binary
   # nroff formats echo.1 into echo.cat1 during this build
   ```

The system can then be packaged or booted from `${DESTDIR}`. Building within a modern environment may require additional patches or legacy toolchains. See the historic notes in `INFO.TXT` for context.
The example above demonstrates that the packaged toolchain is sufficient for at
least simple utilities.

