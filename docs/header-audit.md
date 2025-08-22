# Header Audit Utility

The project includes `scripts/header_audit.py`, a small helper that scans the
source tree for local `#include "..."` directives and reports headers that are
referenced but absent. When invoked with the `--unused` flag it also lists header
files present on disk yet never included, aiding reconciliation of the sources
with the expectations of the build system.

## Usage

```bash
python scripts/header_audit.py [path] [--unused] [--json] [--strict]
```

The optional `path` argument specifies the root directory to examine. When
omitted, the current working directory is scanned. The script searches for C,
header, and assembly sources and emits reports such as:

```
Missing headers detected:
usr/src/foo/bar.c: includes 'missing.h' not found
```

If every include can be resolved, the tool prints `No missing local headers
found.` When `--unused` is supplied an additional section lists headers that are
never referenced:

```
Unused headers:
usr/include/legacy/foo.h
```

### JSON output and strict mode

For machine consumption or continuous‑integration jobs the auditor can emit a
structured JSON report and fail the build when problems are discovered:

```bash
# Produce JSON and exit with code 1 if issues are found
python scripts/header_audit.py --unused --json --strict > audit.json
```

The JSON schema contains two top‑level arrays:

```json
{
  "missing": [{"source": "path/to/file.c", "header": "foo.h"}],
  "unused": ["path/to/obsolete.h"]
}
```

### Ignoring system headers

Many historical sources use quoted includes for operating‑system headers such as
`"sys/param.h"`. The auditor suppresses common system headers by default, but
additional patterns can be ignored via the `--ignore` (or `-i`) flag. Patterns
use the same wildcard syntax as Unix shells:

```bash
# Ignore anything under contrib/ and a custom foo.h
python scripts/header_audit.py -i 'contrib/*' -i foo.h
```

Patterns are matched against the raw include string (e.g. `sys/param.h`).
Internally, the default ignore list already covers typical standard library and
kernel headers.

## Environment

The utility requires only the standard Python 3 runtime. For reproducible
results in this repository, install the documentation toolchain and BSD make
as outlined in [`setup.md`](../setup.md):

```bash
sudo apt-get update
sudo apt-get install -y doxygen bmake
pip install sphinx breathe sphinx-rtd-theme
```

Running `./tests/test_docs.sh` verifies the documentation build, while
`./tests/test_kernel.sh` performs a lightweight kernel build smoke test. These
checks were executed during development of this script to ensure the environment
was configured correctly.
