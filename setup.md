# Setup Guide

This guide outlines the tools required to work with the historic 386BSD source tree and generate documentation.

## Tool installation matrix

The following table summarises canonical installation methods derived from Debian packages, PyPI, npm, and upstream source distributions.

```
+-------------------+--------------------+--------------------------------------------------+
| Tool              | Installation Method| Example Command                                  |
+-------------------+--------------------+--------------------------------------------------+
| lizard            | pip                | pip install lizard                               |
| cloc              | apt                | sudo apt install cloc                            |
| cscope            | apt                | sudo apt install cscope                          |
| diffoscope        | pip                | pip install diffoscope                           |
| dtrace            | Source/Build       | git clone https://github.com/dtrace4linux/linux.git; cd linux; make; sudo make install |
| valgrind          | apt                | sudo apt install valgrind                        |
| cppcheck          | apt                | sudo apt install cppcheck                        |
| sloccount         | apt                | sudo apt install sloccount                       |
| flawfinder        | apt                | sudo apt install flawfinder                      |
| gdb               | apt                | sudo apt install gdb                             |
| pylint            | pip                | pip install pylint                               |
| flake8            | pip                | pip install flake8                               |
| mypy              | pip                | pip install mypy                                 |
| semgrep           | pip                | pip install semgrep                              |
| eslint            | npm                | npm install eslint                               |
| jshint            | npm                | npm install jshint                               |
| jscpd             | npm                | npm install jscpd                                |
| nyc               | npm                | npm install nyc                                  |
+-------------------+--------------------+--------------------------------------------------+
```

For sample outputs see [docs/tooling-report.md](docs/tooling-report.md).

## System packages (APT)

Install the following packages and verify each installation:

```bash
sudo apt-get update
sudo apt-get install -y \
  file \
  bmake \
  doxygen \
  cmake \
  graphviz \
  ninja-build \
  clang \
  lld \
  clang-format \
  clang-tidy \
  cppcheck \
  valgrind \
  gdb \
  cloc \
  cscope \
  sloccount \
  flawfinder

# version checks
file --version
bmake -V MAKE_VERSION
doxygen --version
cmake --version
dot -V
ninja --version
clang --version
lld --version
clang-format --version
clang-tidy --version
cppcheck --version
valgrind --version
gdb --version
cloc --version
cscope -V
sloccount --version
flawfinder --version
```

- **file** – inspect binary formats.
- **bmake** – BSD make compatible with the original build system.
- **doxygen** – generate C reference documentation.
- **cmake** – orchestrate complex builds including documentation.
- **graphviz** – render diagrams for Doxygen.
- **ninja-build** – high-performance build executor and new project entry point.
- **clang** – modern C/C++ compiler used for all builds.
- **lld** – LLVM linker required by the Clang toolchain.
- **clang-format** – enforce consistent code style.
- **clang-tidy** – in-depth static analysis and linting.
- **cppcheck** – additional static analysis for C code.
- **valgrind** – runtime instrumentation and memory debugging.
- **gdb** – interactive debugging of binaries.
- **cloc** – enumerate code volume across languages.
- **cscope** – index C sources for quick symbol lookup.
- **sloccount** – provide language-specific line metrics.
- **flawfinder** – scan for common security weaknesses.

## Python packages (pip)

```bash
pip install sphinx breathe sphinx-rtd-theme lizard diffoscope pylint flake8 mypy semgrep

# verify
python - <<'PY'
import sphinx, breathe
print('sphinx', sphinx.__version__)
print('breathe', breathe.__version__)
PY
lizard --version
diffoscope --version
pylint --version
flake8 --version
mypy --version
semgrep --version
```

- **sphinx** – build developer documentation.
- **breathe** – bridge Doxygen XML into Sphinx.
- **sphinx-rtd-theme** – provide a clean HTML theme.
- **lizard** – measure cyclomatic complexity.
- **diffoscope** – present thorough binary and archive diffs.
- **pylint** – general Python static analysis.
- **flake8** – enforce Python style conventions.
- **mypy** – optional type checking for Python.
- **semgrep** – multi-language semantic search and linting.

## Node tooling

Install JavaScript utilities via `npm` and confirm their versions:

```bash
npm --version
npm install -g eslint jshint jscpd nyc
eslint --version
jshint --version
jscpd --version
nyc --version
```

The command currently warns about the deprecated `http-proxy` environment configuration.

- **eslint** – ECMAScript/TypeScript linting.
- **jshint** – legacy JavaScript linter.
- **jscpd** – detect copy‑and‑paste code.
- **nyc** – JavaScript coverage via Istanbul.

## Additional tools to try

- `doxygen-latex` – PDF outputs.
- `sphinx-autobuild` – live-reloading docs during authoring.
- `qemu-system-i386` – emulate the 386BSD kernel image.

## Running tests

Execute the provided test scripts to verify the build system and documentation:

```bash
./tests/test_kernel.sh
./tests/test_docs.sh
```

`test_kernel.sh` runs `bmake -n` within `usr/src` and warns if the kernel image `386bsd` is missing. `test_docs.sh` drives the integrated CMake, Doxygen, and Sphinx pipeline.

