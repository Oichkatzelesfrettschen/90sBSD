#!/usr/bin/env python3
"""Recursively scan source files for #include directives."""
from __future__ import annotations

import collections
import os
import re
import sys
from typing import DefaultDict, Set

INC_RE = re.compile(r'^\s*#\s*include\s*[<"]([^">]+)[">]')

def walk_sources(root: str) -> DefaultDict[str, Set[str]]:
    graph: DefaultDict[str, Set[str]] = collections.defaultdict(set)
    for dirpath, _, files in os.walk(root):
        for name in files:
            if not name.endswith(('.c', '.h', '.S', '.s')):
                continue
            path = os.path.join(dirpath, name)
            try:
                with open(path, 'r', errors='ignore') as fh:
                    for line in fh:
                        m = INC_RE.match(line)
                        if m:
                            graph[path].add(m.group(1))
            except OSError:
                pass
    return graph

def main(argv: list[str]) -> int:
    root = argv[1] if len(argv) > 1 else '.'
    graph = walk_sources(root)
    for src in sorted(graph):
        for hdr in sorted(graph[src]):
            print(f"{src} -> {hdr}")
    return 0

if __name__ == '__main__':
    raise SystemExit(main(sys.argv))
