# Tooling Execution Report

This report captures configuration notes and sample output for the analysis and build tools used in this repository. Installation instructions reside in [setup.md](../setup.md).

## Build Toolchain

### clang / lld / ninja
- **Install:** `sudo apt-get install clang lld ninja-build`
- **Config:** Relies on `CMakePresets.json` for build presets.
- **Sample:**
```bash
$ clang --version
Ubuntu clang version 18.1.3 (1ubuntu1)
$ ld.lld --version | head -n 1
Ubuntu LLD 18.1.3 (compatible with GNU linkers)
$ ninja --version
1.11.1
```

### clang-format / clang-tidy
- **Install:** `sudo apt-get install clang-format clang-tidy`
- **Config:** Controlled by `.clang-format` and `.clang-tidy` (not yet provided).
- **Sample:**
```bash
$ clang-format --version
clang-format version 20.1.8
$ clang-tidy --version
LLVM (http://llvm.org/):
  LLVM version 20.1.0
```

## C and C++ Analysis

### lizard
- **Install:** `pip install lizard`
- **Config:** optional `.lizardrc`.
- **Sample:**
```bash
$ lizard usr/src/kernel/aux/aux.c | head -n 5
================================================
  NLOC    CCN   token  PARAM  length  location
------------------------------------------------
       8      1     27      1      29 auxprobe@77-105@usr/src/kernel/aux/aux.c
       7      4     50      1       7 while@108-114@usr/src/kernel/aux/aux.c
```

### cloc
- **Install:** `sudo apt-get install cloc`
- **Config:** none.
- **Sample:**
```bash
$ cloc usr/src/kernel/aux | head -n 5
github.com/AlDanial/cloc v 1.98  T=0.02 s (40.1 files/s, 14204.2 lines/s)
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
C                                1             42            103            209
```

### cscope
- **Install:** `sudo apt-get install cscope`
- **Config:** generates `cscope.out` database.
- **Sample:**
```bash
$ cscope -V
cscope: version 15.9
```

### diffoscope
- **Install:** `pip install diffoscope`
- **Config:** none.
- **Sample:** comparing identical files produces no diff.
```bash
$ diffoscope README.md README.md | head -n 5
```

### cppcheck
- **Install:** `sudo apt-get install cppcheck`
- **Config:** `.cppcheck` suppression files (not yet provided).
- **Sample:**
```bash
$ cppcheck usr/src/kernel/aux/aux.c 2>&1 | head -n 5
Checking usr/src/kernel/aux/aux.c ...
usr/src/kernel/aux/aux.c:170:1: error: Found an exit path from function with non-void return type that has missing return statement [missingReturn]
}
^
```

### sloccount
- **Install:** `sudo apt-get install sloccount`
- **Config:** none.
- **Sample:**
```bash
$ sloccount usr/src/kernel/aux 2>&1 | head -n 5
Creating filelist for aux
Categorizing files.
Finding a working MD5 command....
Found a working MD5 command.
```

### flawfinder
- **Install:** `sudo apt-get install flawfinder`
- **Config:** `.flawfinder` file (optional).
- **Sample:**
```bash
$ flawfinder usr/src/kernel/aux/aux.c 2>&1 | head -n 10
Flawfinder version 2.0.19, (C) 2001-2019 David A. Wheeler.
Number of rules (primarily dangerous function names) in C/C++ ruleset: 222
Examining usr/src/kernel/aux/aux.c

FINAL RESULTS:

usr/src/kernel/aux/aux.c:275:  [2] (obsolete) gsignal:
```

### valgrind
- **Install:** `sudo apt-get install valgrind`
- **Config:** none.
- **Sample:**
```bash
$ valgrind true 2>&1 | head -n 5
==6212== Memcheck, a memory error detector
==6212== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==6212== Using Valgrind-3.22.0 and LibVEX; rerun with -h for copyright info
==6212== Command: true
==6212==
```

### gdb
- **Install:** `sudo apt-get install gdb`
- **Config:** `.gdbinit` for custom settings.
- **Sample:**
```bash
$ gdb --version | head -n 1
GNU gdb (Ubuntu 15.0.50.20240403-0ubuntu1) 15.0.50.20240403-git
```

## Python Linting

### pylint
- **Install:** `pip install pylint`
- **Config:** `.pylintrc`.
- **Sample:**
```bash
$ pylint scripts/relativize_symlinks.py | head -n 5
************* Module relativize_symlinks
scripts/relativize_symlinks.py:10:0: C0116: Missing function or method docstring (missing-function-docstring)
scripts/relativize_symlinks.py:23:0: C0116: Missing function or method docstring (missing-function-docstring)
```

### flake8
- **Install:** `pip install flake8`
- **Config:** `.flake8` or `setup.cfg`.
- **Sample:**
```bash
$ flake8 scripts/relativize_symlinks.py
```

### mypy
- **Install:** `pip install mypy`
- **Config:** `mypy.ini` or `pyproject.toml`.
- **Sample:**
```bash
$ mypy scripts/relativize_symlinks.py
Success: no issues found in 1 source file
```

### semgrep
- **Install:** `pip install semgrep`
- **Config:** `.semgrep.yml` (optional) or `--config=auto`.
- **Sample:**
```bash
$ semgrep --config=auto usr/src/kernel/aux/aux.c | tail -n 6
✅ Scan completed successfully.
 • Findings: 0 (0 blocking)
 • Rules run: 53
 • Targets scanned: 1
```

## JavaScript Utilities

### eslint
- **Install:** `npm install -g eslint`
- **Config:** `eslint.config.js`.
- **Sample:**
```bash
$ eslint /tmp/sample.js | head -n 5
ESLint: 9.33.0
ESLint couldn't find an eslint.config.(js|mjs|cjs) file.
```

### jshint
- **Install:** `npm install -g jshint`
- **Config:** `.jshintrc`.
- **Sample:**
```bash
$ jshint /tmp/sample.js
```

### jscpd
- **Install:** `npm install -g jscpd`
- **Config:** `.jscpd.json`.
- **Sample:**
```bash
$ jscpd usr/src/kernel/aux/aux.c | head -n 5
┌────────┬────────────────┬─────────────┬──────────────┬──────────────┬──────────────────┬───────────────────┐
│ Format │ Files analyzed │ Total lines │ Total tokens │ Clones found │ Duplicated lines │ Duplicated tokens │
├────────┼────────────────┼─────────────┼──────────────┼──────────────┼──────────────────┼───────────────────┤
│ c      │ 1              │ 353         │ 1748         │ 0            │ 0 (0%)           │ 0 (0%)            │
```

### nyc
- **Install:** `npm install -g nyc`
- **Config:** `.nycrc`.
- **Sample:**
```bash
$ nyc --version
17.1.0
```

## Additional Tools

### dtrace
- **Install:** source build from https://github.com/dtrace4linux/linux
- **Config:** platform dependent.
- **Sample:** command unavailable by default.
```bash
$ dtrace --version
bash: command not found: dtrace
```

### diffoscope and others
See above sections for usage. Tools producing no output on identical inputs (e.g., diffoscope) confirm clean comparisons.

