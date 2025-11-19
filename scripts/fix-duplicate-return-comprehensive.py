#!/usr/bin/env python3
"""
Fix duplicate return types created by the K&R fixer script.
This looks for patterns like:
  static inline int
  int
  function_name(...)
"""

import os
import re
from pathlib import Path

def fix_duplicates(file_path):
    """Remove duplicate return types."""
    with open(file_path, 'r', encoding='latin-1') as f:
        lines = f.readlines()

    fixed = False
    i = 0
    while i < len(lines) - 2:
        line1 = lines[i].strip()
        line2 = lines[i + 1].strip()

        # Check for patterns like:
        # Line 1: ends with 'int' or 'void' or 'char' etc.
        # Line 2: is ONLY 'int' or 'void' or 'char' etc. (duplicate)
        # Line 3: function name with opening paren

        # Common type keywords
        types = ['int', 'void', 'char', 'long', 'short', 'float', 'double', 'unsigned', 'signed']

        # Check if line 2 is a standalone type (duplicate)
        if line2 in types:
            # Check if line 1 ends with the same type
            if line1.endswith(line2):
                # Check if line 3 looks like a function definition
                if i + 2 < len(lines):
                    line3 = lines[i + 2].strip()
                    # Function name pattern: identifier followed by (
                    if re.match(r'^[a-zA-Z_][a-zA-Z0-9_]*\s*\(', line3):
                        # Remove the duplicate type line
                        del lines[i + 1]
                        fixed = True
                        print(f"  Removed duplicate '{line2}' at line {i+2}")
                        continue  # Don't increment i, check same position again
        i += 1

    if fixed:
        with open(file_path, 'w', encoding='latin-1') as f:
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

print(f"\nFixed {fixed_count} files total")
