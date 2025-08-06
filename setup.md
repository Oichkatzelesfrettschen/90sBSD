# Setup Guide

This guide outlines the tools required to work with the historic 386BSD source tree and generate documentation.

## System packages (APT)

Install the following packages and verify each installation:

```bash
sudo apt-get update
sudo apt-get install -y \
  file \
  bmake \
  doxygen \
  cmake \
  graphviz

# version checks
file --version
bmake -V MAKE_VERSION
doxygen --version
cmake --version
dot -V
```

- **file** – inspect binary formats.
- **bmake** – BSD make compatible with the original build system.
- **doxygen** – generate C reference documentation.
- **cmake** – orchestrate complex builds including documentation.
- **graphviz** – render diagrams for Doxygen.

## Python packages (pip)

```bash
pip install sphinx breathe sphinx-rtd-theme

# verify
python - <<'PY'
import sphinx, breathe
print('sphinx', sphinx.__version__)
print('breathe', breathe.__version__)
PY
```

- **sphinx** – build developer documentation.
- **breathe** – bridge Doxygen XML into Sphinx.
- **sphinx-rtd-theme** – provide a clean HTML theme.

## Node tooling

`npm` is available for JavaScript tooling. No packages were installed, but the version can be checked:

```bash
npm --version
```

The command currently warns about the deprecated `http-proxy` environment configuration.

## Additional tools to try

- `doxygen-latex` – PDF outputs.
- `sphinx-autobuild` – live-reloading docs during authoring.
- `clang-format` – consistent C/C++ formatting.
- `cppcheck` – static analysis for C.
- `qemu-system-i386` – emulate the 386BSD kernel image.

## Running tests

Execute the provided test scripts to verify the build system and documentation:

```bash
./tests/test_kernel.sh
./tests/test_docs.sh
```

`test_kernel.sh` runs `bmake -n` within `usr/src` and warns if the kernel image `386bsd` is missing. `test_docs.sh` drives the integrated CMake, Doxygen, and Sphinx pipeline.
