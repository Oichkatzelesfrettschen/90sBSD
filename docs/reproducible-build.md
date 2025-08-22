# Reproducible Build Environment

This guide captures a known-good configuration for building and auditing
this codebase. Commands are intended to be reproducible on recent
Debian-based distributions.

## Dependencies

```bash
apt-get update
apt-get install -y \\
  clang lld cmake ninja-build python3 python3-pip \\
  graphviz doxygen bmake
pip3 install sphinx myst-parser
```

## Configure and Build

```bash
cmake -S . -B build -G Ninja \
  -DCMAKE_C_COMPILER=$(command -v clang) \
  -DCMAKE_LINKER=$(command -v lld) \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

ninja -C build
```

## Audit Headers

```bash
ninja -C build include-audit
```

## Documentation

```bash
./tests/test_docs.sh
./tests/test_include_audit.sh
./tests/test_kernel.sh
```

These steps establish a repeatable baseline for further experimentation.
