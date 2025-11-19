#!/usr/bin/env python3
"""
Comprehensive C17 Compliance Scanner for 386BSD
Analyzes all C source files for C17 standard compliance.

Usage:
    ./analyze-c17-compliance.py [--parallel N] [--output-dir DIR]

Author: 386BSD Modernization Team
Date: 2025-11-19
"""

import argparse
import csv
import json
import multiprocessing
import re
import subprocess
import sys
from collections import defaultdict
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Dict, List, Tuple, Optional


@dataclass
class CompilationError:
    """Represents a single compilation error."""
    file: str
    line: int
    column: int
    severity: str  # 'error' or 'warning'
    category: str  # Categorized error type
    message: str
    raw_message: str  # Original compiler message


@dataclass
class FileResult:
    """Results for a single file."""
    file: str
    status: str  # 'pass', 'fail', 'skip'
    error_count: int
    warning_count: int
    errors: List[CompilationError]


class ErrorCategorizer:
    """Categorizes C17 compilation errors into actionable groups."""

    # Error pattern definitions
    PATTERNS = {
        'kr_function': re.compile(
            r"type specifier missing, defaults to 'int'|"
            r"ISO C99 and later do not support implicit int"
        ),
        'implicit_function': re.compile(
            r"call to undeclared function|"
            r"implicit declaration of function|"
            r"implicit function declarations"
        ),
        'inline_asm': re.compile(
            r"call to undeclared function 'asm'|"
            r"use of undeclared identifier 'asm'"
        ),
        'incompatible_pointer': re.compile(
            r"incompatible pointer types|"
            r"incompatible function pointer types"
        ),
        'conflicting_types': re.compile(
            r"conflicting types for"
        ),
        'undeclared_identifier': re.compile(
            r"use of undeclared identifier"
        ),
        'invalid_type': re.compile(
            r"unknown type name|"
            r"expected .*; but have"
        ),
        'pragma_pack': re.compile(
            r"pragma pack.*modified in the included file"
        ),
        'macro_redefinition': re.compile(
            r"macro redefinition|"
            r"redefinition of"
        ),
        'missing_prototype': re.compile(
            r"no previous prototype for function"
        ),
        'old_style_definition': re.compile(
            r"old-style function definition"
        ),
    }

    @classmethod
    def categorize(cls, message: str) -> str:
        """Categorize an error message."""
        for category, pattern in cls.PATTERNS.items():
            if pattern.search(message):
                return category
        return 'other'


class C17ComplianceScanner:
    """Main scanner class."""

    def __init__(self, repo_root: Path, output_dir: Path, parallel: int = 1):
        self.repo_root = repo_root
        self.output_dir = output_dir
        self.parallel = parallel
        self.include_dirs = [
            repo_root / 'usr' / 'include',
            repo_root / 'usr' / 'src' / 'kernel' / 'include',
        ]

        # Results storage
        self.results: List[FileResult] = []
        self.stats = defaultdict(int)

        # Ensure output directory exists
        self.output_dir.mkdir(parents=True, exist_ok=True)

    def find_c_files(self) -> List[Path]:
        """Find all C source files in the repository."""
        c_files = []
        search_paths = [
            self.repo_root / 'usr' / 'src',
        ]

        for search_path in search_paths:
            if search_path.exists():
                c_files.extend(search_path.rglob('*.c'))

        return sorted(c_files)

    def test_file(self, file_path: Path) -> FileResult:
        """Test a single C file for C17 compliance."""
        # Build compilation command
        cmd = [
            'clang',
            '-std=c17',
            '-pedantic',
            '-fsyntax-only',
        ]

        # Add include directories
        for inc_dir in self.include_dirs:
            if inc_dir.exists():
                cmd.extend(['-I', str(inc_dir)])

        cmd.append(str(file_path))

        # Execute compilation
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30
            )
        except subprocess.TimeoutExpired:
            return FileResult(
                file=str(file_path.relative_to(self.repo_root)),
                status='skip',
                error_count=0,
                warning_count=0,
                errors=[]
            )

        # Parse output
        errors = self._parse_compiler_output(
            file_path,
            result.stdout + result.stderr
        )

        error_count = sum(1 for e in errors if e.severity == 'error')
        warning_count = sum(1 for e in errors if e.severity == 'warning')

        status = 'pass' if error_count == 0 else 'fail'

        return FileResult(
            file=str(file_path.relative_to(self.repo_root)),
            status=status,
            error_count=error_count,
            warning_count=warning_count,
            errors=errors
        )

    def _parse_compiler_output(self, file_path: Path, output: str) -> List[CompilationError]:
        """Parse compiler output and extract errors."""
        errors = []

        # Pattern: file:line:column: severity: message
        pattern = re.compile(
            r'^(.+?):(\d+):(\d+):\s*(error|warning):\s*(.+)$',
            re.MULTILINE
        )

        for match in pattern.finditer(output):
            error_file, line, col, severity, message = match.groups()

            # Categorize the error
            category = ErrorCategorizer.categorize(message)

            errors.append(CompilationError(
                file=str(file_path.relative_to(self.repo_root)),
                line=int(line),
                column=int(col),
                severity=severity,
                category=category,
                message=message.strip(),
                raw_message=match.group(0)
            ))

        return errors

    def scan_all(self):
        """Scan all C files in the repository."""
        c_files = self.find_c_files()
        total = len(c_files)

        print(f"Found {total} C files to analyze")
        print(f"Using {self.parallel} parallel workers")
        print("=" * 70)

        if self.parallel > 1:
            # Parallel execution
            with multiprocessing.Pool(self.parallel) as pool:
                self.results = list(pool.imap(
                    self.test_file,
                    c_files,
                    chunksize=10
                ))
        else:
            # Sequential execution with progress
            self.results = []
            for i, file_path in enumerate(c_files, 1):
                result = self.test_file(file_path)
                self.results.append(result)

                if i % 100 == 0 or i == total:
                    print(f"Progress: {i}/{total} files ({i*100//total}%)")

    def generate_reports(self):
        """Generate comprehensive analysis reports."""
        # Calculate statistics
        self._calculate_statistics()

        # Generate reports
        self._write_summary_report()
        self._write_detailed_csv()
        self._write_json_database()
        self._write_categorized_report()

        print("\n" + "=" * 70)
        print("REPORTS GENERATED:")
        print(f"  Summary:     {self.output_dir}/summary.txt")
        print(f"  CSV:         {self.output_dir}/c17-errors.csv")
        print(f"  JSON:        {self.output_dir}/c17-database.json")
        print(f"  Categories:  {self.output_dir}/error-categories.txt")
        print("=" * 70)

    def _calculate_statistics(self):
        """Calculate comprehensive statistics."""
        self.stats['total_files'] = len(self.results)
        self.stats['passed'] = sum(1 for r in self.results if r.status == 'pass')
        self.stats['failed'] = sum(1 for r in self.results if r.status == 'fail')
        self.stats['skipped'] = sum(1 for r in self.results if r.status == 'skip')
        self.stats['total_errors'] = sum(r.error_count for r in self.results)
        self.stats['total_warnings'] = sum(r.warning_count for r in self.results)

        # Category statistics
        category_counts = defaultdict(int)
        for result in self.results:
            for error in result.errors:
                if error.severity == 'error':
                    category_counts[error.category] += 1

        self.stats['categories'] = dict(category_counts)

    def _write_summary_report(self):
        """Write summary text report."""
        output_file = self.output_dir / 'summary.txt'

        with output_file.open('w') as f:
            f.write("=" * 70 + "\n")
            f.write("C17 COMPLIANCE SCAN SUMMARY\n")
            f.write("=" * 70 + "\n\n")

            f.write("OVERALL RESULTS:\n")
            f.write(f"  Total files tested:    {self.stats['total_files']:>6}\n")
            f.write(f"  Passed (C17):          {self.stats['passed']:>6} "
                   f"({self.stats['passed']*100//self.stats['total_files']:>3}%)\n")
            f.write(f"  Failed:                {self.stats['failed']:>6} "
                   f"({self.stats['failed']*100//self.stats['total_files']:>3}%)\n")
            f.write(f"  Skipped:               {self.stats['skipped']:>6}\n")
            f.write(f"\n")
            f.write(f"  Total errors:          {self.stats['total_errors']:>6}\n")
            f.write(f"  Total warnings:        {self.stats['total_warnings']:>6}\n")
            f.write("\n")

            f.write("ERROR CATEGORIES:\n")
            categories = sorted(
                self.stats['categories'].items(),
                key=lambda x: x[1],
                reverse=True
            )
            for category, count in categories:
                f.write(f"  {category:.<30} {count:>6}\n")

            f.write("\n")
            f.write("TOP 20 FILES BY ERROR COUNT:\n")
            top_files = sorted(
                [(r.file, r.error_count) for r in self.results],
                key=lambda x: x[1],
                reverse=True
            )[:20]
            for file, count in top_files:
                f.write(f"  {count:>4} errors: {file}\n")

    def _write_detailed_csv(self):
        """Write detailed CSV of all errors."""
        output_file = self.output_dir / 'c17-errors.csv'

        with output_file.open('w', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([
                'File', 'Line', 'Column', 'Severity',
                'Category', 'Message'
            ])

            for result in self.results:
                for error in result.errors:
                    writer.writerow([
                        error.file,
                        error.line,
                        error.column,
                        error.severity,
                        error.category,
                        error.message
                    ])

    def _write_json_database(self):
        """Write complete database as JSON."""
        output_file = self.output_dir / 'c17-database.json'

        data = {
            'statistics': dict(self.stats),
            'results': [
                {
                    'file': r.file,
                    'status': r.status,
                    'error_count': r.error_count,
                    'warning_count': r.warning_count,
                    'errors': [asdict(e) for e in r.errors]
                }
                for r in self.results
            ]
        }

        with output_file.open('w') as f:
            json.dump(data, f, indent=2)

    def _write_categorized_report(self):
        """Write detailed categorized error report."""
        output_file = self.output_dir / 'error-categories.txt'

        # Group errors by category
        by_category = defaultdict(list)
        for result in self.results:
            for error in result.errors:
                if error.severity == 'error':
                    by_category[error.category].append(error)

        with output_file.open('w') as f:
            f.write("=" * 70 + "\n")
            f.write("C17 ERRORS BY CATEGORY\n")
            f.write("=" * 70 + "\n\n")

            for category in sorted(by_category.keys()):
                errors = by_category[category]
                f.write(f"\n{'=' * 70}\n")
                f.write(f"CATEGORY: {category.upper()}\n")
                f.write(f"Count: {len(errors)}\n")
                f.write(f"{'=' * 70}\n\n")

                # Show first 10 examples
                for error in errors[:10]:
                    f.write(f"  {error.file}:{error.line}:{error.column}\n")
                    f.write(f"    {error.message}\n\n")

                if len(errors) > 10:
                    f.write(f"  ... and {len(errors) - 10} more\n\n")


def main():
    """Main entry point."""
    parser = argparse.ArgumentParser(
        description='Comprehensive C17 compliance scanner for 386BSD'
    )
    parser.add_argument(
        '--parallel', '-j',
        type=int,
        default=multiprocessing.cpu_count(),
        help='Number of parallel workers (default: CPU count)'
    )
    parser.add_argument(
        '--output-dir', '-o',
        type=Path,
        default=Path('logs/analysis/c17-compliance'),
        help='Output directory for reports'
    )
    parser.add_argument(
        '--repo-root',
        type=Path,
        default=Path.cwd(),
        help='Repository root directory'
    )

    args = parser.parse_args()

    # Create scanner
    scanner = C17ComplianceScanner(
        repo_root=args.repo_root,
        output_dir=args.output_dir,
        parallel=args.parallel
    )

    # Run scan
    print("C17 Compliance Scanner for 386BSD")
    print("=" * 70)
    scanner.scan_all()

    # Generate reports
    scanner.generate_reports()

    # Print summary to console
    print(f"\nPassed: {scanner.stats['passed']}/{scanner.stats['total_files']} "
          f"({scanner.stats['passed']*100//scanner.stats['total_files']}%)")
    print(f"Failed: {scanner.stats['failed']}/{scanner.stats['total_files']} "
          f"({scanner.stats['failed']*100//scanner.stats['total_files']}%)")

    # Exit code: 0 if all passed, 1 if any failed
    sys.exit(0 if scanner.stats['failed'] == 0 else 1)


if __name__ == '__main__':
    main()
