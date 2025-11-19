#!/usr/bin/env python3
"""
Extract all files with exactly N errors and categorize by error type.
"""

import json
import sys
from collections import defaultdict

def main():
    if len(sys.argv) < 2:
        print("Usage: extract-n-error-files.py <error_count>")
        sys.exit(1)

    target_errors = int(sys.argv[1])

    # Load C17 database
    with open('logs/analysis/c17-compliance/c17-database.json') as f:
        data = json.load(f)

    # Extract files with exactly N errors
    files_by_category = defaultdict(list)

    for result in data['results']:
        if result['status'] == 'fail' and result['error_count'] == target_errors:
            # Determine primary error category
            categories = defaultdict(int)
            for error in result.get('errors', []):
                if error.get('severity') == 'error':
                    cat = error.get('category', 'unknown')
                    categories[cat] += 1

            # Get dominant category (most errors)
            if categories:
                primary_cat = max(categories.items(), key=lambda x: x[1])[0]
                files_by_category[primary_cat].append(result['file'])

    # Print summary
    print(f"=" * 80)
    print(f"FILES WITH EXACTLY {target_errors} ERROR(S)")
    print(f"=" * 80)
    print()

    total_files = sum(len(files) for files in files_by_category.values())

    for category in sorted(files_by_category.keys()):
        files = files_by_category[category]
        print(f"{category:30s} {len(files):3d} files")

    print(f"\n{'Total':30s} {total_files:3d} files")
    print()

    # Save category-specific file lists
    for category, files in files_by_category.items():
        filename = f"/tmp/{target_errors}error_{category}_files.txt"
        with open(filename, 'w') as f:
            for file_path in sorted(files):
                f.write(f"{file_path}\n")
        print(f"Saved: {filename} ({len(files)} files)")

    # Save all files list
    all_filename = f"/tmp/{target_errors}error_all_files.txt"
    all_files = []
    for files in files_by_category.values():
        all_files.extend(files)
    with open(all_filename, 'w') as f:
        for file_path in sorted(all_files):
            f.write(f"{file_path}\n")
    print(f"Saved: {all_filename} ({len(all_files)} files)")

    return files_by_category

if __name__ == '__main__':
    main()
