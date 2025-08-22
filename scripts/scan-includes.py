#!/usr/bin/env python3
"""Recursively scan source files for ``#include`` directives.

The utility walks a source tree, collects all ``#include`` statements
and optionally verifies that the referenced headers exist. This helps
audit historic code for stale or missing dependencies.
"""
from __future__ import annotations

import argparse
import json
import os
import re
import shlex
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import DefaultDict, Dict, Iterable, List, Set

INC_RE = re.compile(r'^\s*#\s*include\s*[<"]([^">]+)[">]')


@dataclass
class IncludeEntry:
    """Record of a single ``#include`` reference."""

    source: Path
    header: str
    found: bool


def walk_sources(root: Path) -> DefaultDict[Path, Set[str]]:
    """Return a mapping of source paths to the headers they include."""

    graph: DefaultDict[Path, Set[str]] = defaultdict(set)
    root = root.resolve()
    for dirpath, _, files in os.walk(root):
        for name in files:
            if not name.endswith((".c", ".h", ".S", ".s")):
                continue
            path = Path(dirpath, name).resolve()
            try:
                with open(path, "r", errors="ignore") as fh:
                    for line in fh:
                        match = INC_RE.match(line)
                        if match:
                            graph[path].add(match.group(1))
            except OSError:
                # Skip files that cannot be read
                pass
    return graph


def header_exists(header: str, search_dirs: Iterable[Path]) -> bool:
    """Return True if ``header`` is found in ``search_dirs``."""

    return any((d / header).exists() for d in search_dirs)


def parse_compile_commands(path: str) -> Dict[Path, List[Path]]:
    """Parse ``compile_commands.json`` mapping sources to include directories."""

    mapping: Dict[Path, List[Path]] = {}
    try:
        with open(path, "r", encoding="utf-8") as fh:
            database = json.load(fh)
    except OSError:
        return mapping

    for entry in database:
        directory = Path(entry.get("directory", ".")).resolve()
        source = (directory / entry.get("file", "")).resolve()
        args = entry.get("arguments")
        if args is None:
            args = shlex.split(entry.get("command", ""))
        includes: List[Path] = []
        it = iter(args)
        for token in it:
            if token == "-I":
                includes.append((directory / next(it, "")).resolve())
            elif token.startswith("-I"):
                includes.append((directory / token[2:]).resolve())
        mapping[source] = includes
    return mapping


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", help="root directory to scan")
    parser.add_argument(
        "-I",
        "--include-dir",
        dest="includes",
        action="append",
        default=[],
        help="additional include directories for header resolution",
    )
    parser.add_argument(
        "--missing-only", action="store_true", help="print only missing headers"
    )
    parser.add_argument(
        "--compile-commands",
        help="path to compile_commands.json for include discovery",
    )
    parser.add_argument(
        "--json", action="store_true", help="emit machine-readable JSON report"
    )
    args = parser.parse_args(argv[1:])

    graph = walk_sources(Path(args.root))
    search_dirs = [Path(p).resolve() for p in args.includes]
    compile_map = (
        parse_compile_commands(args.compile_commands) if args.compile_commands else {}
    )

    entries: List[IncludeEntry] = []
    root_abs = Path(args.root).resolve()
    for src in sorted(graph):
        includes = search_dirs + compile_map.get(src, [])
        for hdr in sorted(graph[src]):
            found = header_exists(hdr, includes)
            if args.missing_only and found:
                continue
            try:
                rel_src = src.relative_to(root_abs)
            except ValueError:
                rel_src = src
            entries.append(IncludeEntry(source=rel_src, header=hdr, found=found))

    if args.json:
        payload = [
            {"source": str(e.source), "header": e.header, "found": e.found}
            for e in entries
        ]
        print(json.dumps(payload, indent=2))
    else:
        for e in entries:
            status = "ok" if e.found else "MISSING"
            print(f"{e.source} -> {e.header} [{status}]")

    missing = any(not e.found for e in entries)
    return 1 if missing else 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
