#!/usr/bin/env python3
"""
Fix 'main must return int' errors by changing main() return type to int.
"""

import re
import sys
import json

def fix_main_return(file_path, main_line):
    """Fix main function to return int."""
    with open(file_path, 'r') as f:
        lines = f.readlines()

    # Find main function declaration around the specified line
    # Usually the error points to where main is defined
    for i in range(max(0, main_line - 10), min(len(lines), main_line + 5)):
        line = lines[i]

        # Look for main( pattern
        if re.search(r'\bmain\s*\(', line):
            # Check if it already has int
            if re.search(r'\bint\s+main\s*\(', line):
                return False, "Already has int"

            # Check if it has void
            if re.search(r'\bvoid\s+main\s*\(', line):
                # Replace void with int
                lines[i] = re.sub(r'\bvoid\s+main\s*\(', 'int main(', line)
                with open(file_path, 'w') as f:
                    f.writelines(lines)
                return True, "Changed void to int"

            # Check if main is at start of line (no return type)
            if re.match(r'^\s*main\s*\(', line):
                # Add int before main
                lines[i] = re.sub(r'^(\s*)main\s*\(', r'\1int main(', line)
                with open(file_path, 'w') as f:
                    f.writelines(lines)
                return True, "Added int"

    return False, "Could not find main"

def main():
    # Load C17 database to get line numbers
    with open('logs/analysis/c17-compliance/c17-database.json') as f:
        c17_data = json.load(f)

    # Find all files with "main must return int" error
    main_fixes = {}

    for result in c17_data['results']:
        if result['status'] == 'fail':
            for error in result.get('errors', []):
                if error.get('severity') == 'error' and "'main' must return 'int'" in error['message']:
                    main_fixes[result['file']] = error['line']
                    break

    print("=" * 80)
    print("FIXING 'main must return int' ERRORS")
    print("=" * 80)
    print(f"\nProcessing {len(main_fixes)} files...")
    print()

    fixed_count = 0
    failed_count = 0

    for file_path, line_num in sorted(main_fixes.items()):
        try:
            success, msg = fix_main_return(file_path, line_num)
            if success:
                print(f"✓ {file_path:60s} {msg}")
                fixed_count += 1
            else:
                print(f"○ {file_path:60s} {msg}")
        except Exception as e:
            print(f"✗ {file_path:60s} ERROR: {e}")
            failed_count += 1

    print()
    print("=" * 80)
    print(f"RESULTS:")
    print(f"  Fixed:  {fixed_count:3d} files")
    print(f"  Failed: {failed_count:3d} files")
    print(f"  Total:  {len(main_fixes):3d} files")

if __name__ == '__main__':
    main()
