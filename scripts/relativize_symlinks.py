#!/usr/bin/env python3
"""Utility to convert absolute symlinks to relative within the repository."""
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PLACEHOLDER_ROOT = ROOT / 'placeholder'


def relativize_symlink(link: Path) -> None:
    target = os.readlink(link)
    if not os.path.isabs(target):
        return
    # compute new target relative to placeholder root
    new_target = PLACEHOLDER_ROOT.joinpath(target.lstrip('/'))
    # ensure placeholder target directory exists (no files created)
    new_target.parent.mkdir(parents=True, exist_ok=True)
    rel = os.path.relpath(new_target, link.parent)
    link.unlink()
    link.symlink_to(rel)


def main() -> None:
    PLACEHOLDER_ROOT.mkdir(exist_ok=True)
    for path in ROOT.rglob('*'):
        if path.is_symlink():
            relativize_symlink(path)


if __name__ == '__main__':
    main()
