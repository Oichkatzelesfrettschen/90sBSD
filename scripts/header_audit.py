#!/usr/bin/env python3
"""Audit the tree for missing and unused local ``#include`` directives.

The auditor traverses the source tree rooted at ``root`` and inspects C and
assembly files for directives of the form ``#include "path"``. Each quoted
header is resolved relative to the including file and repository root. Missing
headers that do not match a known system pattern are reported. Optionally, the
utility can also flag *unused* headers that exist on disk but are never
referenced by any source file in the scan.

Example usage::

    # report both missing and unused local headers
    python scripts/header_audit.py path/to/tree --unused

Additional include patterns can be ignored via ``--ignore`` options. Patterns
use Unix shell wildcards as understood by :mod:`fnmatch`.
"""
from __future__ import annotations

import argparse
import fnmatch
import json
import re
from dataclasses import dataclass
from pathlib import Path

# Match lines like: #include "foo.h"
INCLUDE_RE = re.compile(r'^\s*#\s*include\s+"([^"\n]+)"')

# Common system header prefixes or names that should be ignored by default.
DEFAULT_IGNORES = {
    "sys/*",
    "machine/*",
    "net/*",
    "ufs/*",
    "vm/*",
    "X*",
    "xf86*",
    "errno.h",
    "stddef.h",
    "stdint.h",
    "stdio.h",
    "stdlib.h",
    "string.h",
    "time.h",
    "unistd.h",
    "malloc.h",
}


@dataclass
class AuditResult:
    """Structured representation of audit findings."""

    missing: list[tuple[str, Path]]
    unused: list[Path]


def should_ignore(header: str, patterns: set[str]) -> bool:
    """Return ``True`` if *header* matches any pattern in *patterns*.

    Pattern semantics follow :func:`fnmatch.fnmatch` and therefore accept
    wildcards such as ``sys/*``.
    """

    return any(fnmatch.fnmatch(header, pat) for pat in patterns)


def audit(root: Path, ignore: set[str]) -> tuple[list[tuple[str, Path]], set[Path]]:
    """Return unresolved includes and the set of resolved headers.

    Parameters
    ----------
    root:
        Root directory of the source tree to scan.
    ignore:
        ``fnmatch`` patterns specifying headers to skip.

    Returns
    -------
    missing:
        List of tuples ``(header, source)`` for includes that could not be
        resolved relative to *root*.
    referenced:
        Set of header :class:`Path` objects that were successfully resolved and
        therefore referenced by at least one source file.
    """

    missing: list[tuple[str, Path]] = []
    referenced: set[Path] = set()

    for path in root.rglob("*"):
        if path.suffix.lower() not in {".c", ".h", ".s", ".S"}:
            continue
        try:
            text = path.read_text(errors="ignore")
        except OSError:
            continue
        for line in text.splitlines():
            m = INCLUDE_RE.match(line)
            if not m:
                continue
            inc = m.group(1)
            if should_ignore(inc, ignore):
                continue
            candidates = [path.parent / inc, root / inc]
            found = False
            for candidate in candidates:
                if candidate.exists():
                    try:
                        rel = candidate.resolve().relative_to(root.resolve())
                    except ValueError:
                        continue
                    referenced.add(rel)
                    found = True
                    break
            if not found:
                missing.append((inc, path))

    return missing, referenced


def find_unused(root: Path, referenced: set[Path], ignore: set[str]) -> list[Path]:
    """Return headers under *root* that are never referenced."""

    unused: list[Path] = []
    for header in root.rglob("*.h"):
        try:
            rel = header.resolve().relative_to(root.resolve())
        except ValueError:
            continue
        if should_ignore(str(rel), ignore):
            continue
        if rel not in referenced:
            unused.append(rel)
    return unused


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audit local header includes")
    parser.add_argument(
        "root",
        nargs="?",
        default=Path.cwd(),
        type=Path,
        help="Root of tree to scan",
    )
    parser.add_argument(
        "--ignore",
        "-i",
        action="append",
        default=[],
        metavar="PATTERN",
        help="Additional fnmatch patterns to ignore",
    )
    parser.add_argument(
        "--unused",
        "-u",
        action="store_true",
        help="Report headers present on disk but never included",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit findings as JSON for machine consumption",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Return exit status 1 if issues are found",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    ignore: set[str] = DEFAULT_IGNORES | set(args.ignore)
    missing, referenced = audit(args.root, ignore)
    unused: list[Path] = []
    if args.unused:
        unused = find_unused(args.root, referenced, ignore)

    result = AuditResult(missing=missing, unused=unused)

    if args.json:
        payload = {
            "missing": [
                {"source": str(src), "header": inc} for inc, src in result.missing
            ],
            "unused": [str(hdr) for hdr in sorted(result.unused)],
        }
        print(json.dumps(payload, indent=2))
    else:
        if result.missing:
            print("Missing headers detected:")
            for inc, src in result.missing:
                print(f"{src}: includes '{inc}' not found")
        else:
            print("No missing local headers found.")
        if args.unused:
            if result.unused:
                print("\nUnused headers:")
                for hdr in sorted(result.unused):
                    print(hdr)
            else:
                print("\nNo unused headers detected.")

    if args.strict and (result.missing or result.unused):
        raise SystemExit(1)


if __name__ == "__main__":
    main()
