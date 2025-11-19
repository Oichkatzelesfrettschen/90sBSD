#!/usr/bin/env python3
"""
Fix duplicate return types created by the K&R fixer script.
"""

import os
import re
from pathlib import Path

def fix_duplicates(file_path):
    """Remove duplicate return types."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    fixed = False
    i = 0
    while i < len(lines) - 1:
        # Check if current line is a standalone type
        if lines[i].strip() in ['int', 'void']:
            # Check if next line is also a standalone type
            if lines[i + 1].strip() in ['int', 'void', 'static']:
                # Remove the first occurrence
                del lines[i]
                fixed = True
                continue  # Don't increment i, check same position again
        i += 1

    if fixed:
        with open(file_path, 'w') as f:
            f.writelines(lines)
        return True
    return False

# Find and fix all C files
fixed_count = 0
for path in Path('usr/src').rglob('*.c'):
    try:
        if fix_duplicates(path):
            print(f"✓ Fixed: {path}")
            fixed_count += 1
    except Exception as e:
        print(f"✗ Error in {path}: {e}")

print(f"\nFixed {fixed_count} files")
