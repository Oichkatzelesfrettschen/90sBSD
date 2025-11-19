#!/usr/bin/env python3
"""
Fix multiple K&R-style functions in files by inferring return types.
Handles files with 2+ K&R functions that need fixing.
"""

import re
import sys
import json
from pathlib import Path

def find_function_body(lines, start_line):
    """Find the complete function body starting from line."""
    brace_count = 0
    in_function = False
    body_lines = []

    for i in range(start_line, len(lines)):
        line = lines[i]
        body_lines.append(line)

        brace_count += line.count('{')
        brace_count -= line.count('}')

        if '{' in line:
            in_function = True

        if in_function and brace_count == 0:
            return body_lines

    return body_lines

def has_return_value(body_lines):
    """Check if function has return statement with value."""
    for line in body_lines:
        # Look for return statements with values
        if re.search(r'\breturn\s*\(', line) or re.search(r'\breturn\s+[^;]', line):
            # Check if it's not just "return;"
            if not re.search(r'\breturn\s*;', line):
                return True
    return False

def fix_kr_function(file_path, line_numbers):
    """Fix multiple K&R functions at the specified lines."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    # Process in reverse order so line numbers stay valid
    fixes = []
    for line_num in sorted(line_numbers, reverse=True):
        func_line_idx = line_num - 1  # Convert to 0-indexed

        if func_line_idx >= len(lines):
            continue

        # Get function body
        body = find_function_body(lines, func_line_idx)

        # Infer return type
        if has_return_value(body):
            return_type = "int"
        else:
            return_type = "void"

        # Insert return type before function name
        original_line = lines[func_line_idx]
        # Check if already has a type (avoid double-adding)
        if func_line_idx > 0:
            prev_line = lines[func_line_idx - 1].strip()
            if prev_line in ['int', 'void', 'char', 'static', 'extern']:
                # Already has type, skip
                continue

        modified_line = return_type + "\n" + original_line
        lines[func_line_idx] = modified_line
        fixes.append((line_num, return_type))

    # Write back
    if fixes:
        with open(file_path, 'w') as f:
            f.writelines(lines)

    return fixes

def main():
    # Load fixes JSON
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as f:
            kr_fixes = json.load(f)
    else:
        print("Usage: fix-kr-functions-multi.py <fixes_json>")
        sys.exit(1)

    print("=" * 80)
    print("BATCH FIXING K&R FUNCTIONS WITH RETURN TYPE INFERENCE")
    print("=" * 80)
    print(f"\nProcessing {len(kr_fixes)} files...")
    print()

    total_functions = 0
    void_count = 0
    int_count = 0

    for file_path, line_numbers in sorted(kr_fixes.items()):
        try:
            fixes = fix_kr_function(file_path, line_numbers)
            if fixes:
                total_functions += len(fixes)
                for line_num, return_type in fixes:
                    if return_type == 'void':
                        void_count += 1
                    else:
                        int_count += 1
                types_str = ', '.join(f"L{ln}→{rt}" for ln, rt in fixes)
                print(f"✓ {file_path:60s} [{types_str}]")
            else:
                print(f"○ {file_path:60s} [already fixed]")
        except Exception as e:
            print(f"✗ {file_path:60s} ERROR: {e}")

    print()
    print("=" * 80)
    print(f"RESULTS:")
    print(f"  Files processed: {len(kr_fixes)}")
    print(f"  Functions fixed: {total_functions}")
    print(f"  void:            {void_count}")
    print(f"  int:             {int_count}")

if __name__ == '__main__':
    main()
