# Header Audit

The `scan-includes.py` utility inspects the source tree for `#include`
statements and verifies that referenced headers exist. This helps uncover
stale references that would otherwise surface during a build.

## Usage

```bash
python3 scripts/scan-includes.py usr/src \
  -I usr/include -I usr/src/include -I usr/src/lib/libc/include \
  --missing-only
```

The command exits with a non-zero status if any headers are missing. Each
reported line follows the format:

```
path/to/file.c -> sys/obsolete.h [MISSING]
```

## Example

A quick audit of the `usr/src/bin/echo` directory:

```bash
python3 scripts/scan-includes.py usr/src/bin/echo \
  -I usr/include -I usr/src/include -I usr/src/lib/libc/include
```

```text
usr/src/bin/echo/echo.c -> stdio.h [ok]
```

This indicates all local headers resolve correctly for that component.

## Machine-Readable Output

For automated tooling, a structured JSON report can be generated:

```bash
python3 scripts/scan-includes.py usr/src/bin/echo \
  -I usr/include -I usr/src/include -I usr/src/lib/libc/include \
  --json
```

Each entry in the resulting array records the source file, header, and
resolution status, facilitating downstream analysis.

## CMake Integration

To drive the audit from the build system, configure CMake to emit
`compile_commands.json` and invoke the dedicated target:

```bash
cmake -S . -B build -G Ninja \
  -DCMAKE_C_COMPILER=$(command -v clang) \
  -DCMAKE_LINKER=$(command -v lld) \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

ninja -C build include-audit
```

The custom target delegates to `scan-includes.py` using the generated
`compile_commands.json` for include discovery, ensuring the audit mirrors
the active build configuration.
