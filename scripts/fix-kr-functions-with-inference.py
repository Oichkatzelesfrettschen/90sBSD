#!/usr/bin/env python3
"""
Fix K&R-style functions by inferring return types.
Analyzes functions to determine if they should be void or int.
"""

import re
import sys
import json
from pathlib import Path

def find_function_body(lines, start_line):
    """Find the complete function body starting from line."""
    # Start from the function declaration
    brace_count = 0
    in_function = False
    body_lines = []

    for i in range(start_line, len(lines)):
        line = lines[i]
        body_lines.append(line)

        # Count braces
        brace_count += line.count('{')
        brace_count -= line.count('}')

        if '{' in line:
            in_function = True

        if in_function and brace_count == 0:
            # Function complete
            return body_lines

    return body_lines

def has_return_value(body_lines):
    """Check if function has return statement with value."""
    for line in body_lines:
        # Look for return statements
        if re.search(r'\breturn\s*\(', line) or re.search(r'\breturn\s+[^;]', line):
            # Check if it's not just "return;"
            if not re.search(r'\breturn\s*;', line):
                return True
    return False

def fix_kr_function(file_path, line_num):
    """Fix a single K&R function at the specified line."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    # Find function signature (line_num is 1-indexed)
    func_line_idx = line_num - 1

    if func_line_idx >= len(lines):
        return False, "Line number out of range"

    # Get function body
    body = find_function_body(lines, func_line_idx)

    # Infer return type
    if has_return_value(body):
        return_type = "int"
    else:
        return_type = "void"

    # Insert return type before function name
    original_line = lines[func_line_idx]
    modified_line = return_type + "\n" + original_line
    lines[func_line_idx] = modified_line

    # Write back
    with open(file_path, 'w') as f:
        f.writelines(lines)

    return True, return_type

def main():
    # Load the list of files with single kr_function error
    with open('/tmp/low_error_files.json') as f:
        low_error_files = json.load(f)

    # Get kr_function files with 1 error
    kr_files = [f for f in low_error_files
                if f['error_count'] == 1 and 'kr_function' in f['categories']]

    print(f"Found {len(kr_files)} files with 1 kr_function error")

    # Load detailed error info
    with open('logs/analysis/c17-compliance-post-kr-main/c17-database.json') as f:
        data = json.load(f)

    # Build file -> line number mapping
    kr_fixes = {}
    for result in data['results']:
        if result['file'] in [f['file'] for f in kr_files]:
            for error in result.get('errors', []):
                if error.get('severity') == 'error' and error.get('category') == 'kr_function':
                    kr_fixes[result['file']] = error['line']

    print(f"\nProcessing {len(kr_fixes)} files...")
    print("=" * 80)

    fixed_count = 0
    void_count = 0
    int_count = 0

    for file_path, line_num in sorted(kr_fixes.items()):
        try:
            success, return_type = fix_kr_function(file_path, line_num)
            if success:
                fixed_count += 1
                if return_type == 'void':
                    void_count += 1
                else:
                    int_count += 1
                print(f"✓ {file_path}:{line_num} → {return_type}")
        except Exception as e:
            print(f"✗ {file_path}:{line_num} → ERROR: {e}")

    print("=" * 80)
    print(f"\nResults:")
    print(f"  Fixed: {fixed_count}/{len(kr_fixes)}")
    print(f"  void:  {void_count}")
    print(f"  int:   {int_count}")

if __name__ == '__main__':
    main()
