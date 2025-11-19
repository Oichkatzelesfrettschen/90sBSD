#!/usr/bin/env python3
"""
Fix undeclared identifier errors by adding appropriate includes/declarations.
"""

import re
import sys
import json
from pathlib import Path

# Map common undeclared identifiers to headers
IDENTIFIER_TO_HEADER = {
    '_JBLEN': 'setjmp.h',
    'BUFSIZ': 'stdio.h',
    'FILE': 'stdio.h',
    'size_t': 'stddef.h',
    'NULL': 'stddef.h',
    'EOF': 'stdio.h',
}

def extract_identifier(error_message):
    """Extract identifier name from error message."""
    match = re.search(r"use of undeclared identifier '(\w+)'", error_message)
    if match:
        return match.group(1)
    return None

def has_include(lines, header):
    """Check if file already includes the header."""
    for line in lines:
        if f'#include <{header}>' in line or f'#include "{header}"' in line:
            return True
    return False

def add_header(file_path, header):
    """Add a header include to the file."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    if has_include(lines, header):
        return False, "Already included"

    # Find position after last #include
    insert_pos = 0
    for i, line in enumerate(lines):
        if line.startswith('#include'):
            insert_pos = i + 1

    if insert_pos == 0:
        # No includes found, add after comments
        in_comment = False
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped.startswith('/*'):
                in_comment = True
            if in_comment and stripped.endswith('*/'):
                in_comment = False
                continue
            if not in_comment and stripped and not stripped.startswith('//'):
                insert_pos = i
                break

    lines.insert(insert_pos, f'#include <{header}>\n')

    with open(file_path, 'w') as f:
        f.writelines(lines)

    return True, "Added"

def fix_file(file_path, c17_data):
    """Fix undeclared identifier errors in a file."""
    file_data = None
    for result in c17_data['results']:
        if result['file'] == file_path:
            file_data = result
            break

    if not file_data:
        return 0, []

    headers_added = []
    unknown_identifiers = []

    for error in file_data.get('errors', []):
        if error.get('severity') == 'error' and error.get('category') == 'undeclared_identifier':
            ident = extract_identifier(error['message'])
            if ident and ident in IDENTIFIER_TO_HEADER:
                header = IDENTIFIER_TO_HEADER[ident]
                success, msg = add_header(file_path, header)
                if success and header not in headers_added:
                    headers_added.append(header)
            elif ident and ident not in unknown_identifiers:
                unknown_identifiers.append(ident)

    return len(headers_added), unknown_identifiers

def main():
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as f:
            file_list = [line.strip() for line in f if line.strip()]
    else:
        print("Usage: fix-undeclared-identifiers.py <file_list>")
        sys.exit(1)

    with open('logs/analysis/c17-compliance/c17-database.json') as f:
        c17_data = json.load(f)

    print("=" * 80)
    print("BATCH FIXING UNDECLARED IDENTIFIERS")
    print("=" * 80)
    print(f"\nProcessing {len(file_list)} files...")
    print()

    total_fixed = 0
    total_unknown = 0

    for file_path in file_list:
        headers_count, unknown = fix_file(file_path, c17_data)

        if headers_count > 0:
            print(f"✓ {file_path:60s} (+{headers_count} headers)")
            total_fixed += 1
        elif unknown:
            print(f"? {file_path:60s} Unknown: {', '.join(unknown[:3])}")
            total_unknown += 1
        else:
            print(f"○ {file_path:60s} (no changes)")

    print()
    print("=" * 80)
    print(f"RESULTS:")
    print(f"  Fixed:   {total_fixed:3d} files")
    print(f"  Unknown: {total_unknown:3d} files")
    print(f"  Total:   {len(file_list):3d} files")

if __name__ == '__main__':
    main()
