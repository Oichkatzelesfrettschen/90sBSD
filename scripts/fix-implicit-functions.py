#!/usr/bin/env python3
"""
Fix implicit function declarations by adding missing standard headers.
"""

import re
import sys
import json
from pathlib import Path

# Map of function names to headers
FUNCTION_TO_HEADER = {
    'exit': 'stdlib.h',
    'malloc': 'stdlib.h',
    'free': 'stdlib.h',
    'calloc': 'stdlib.h',
    'realloc': 'stdlib.h',
    'atoi': 'stdlib.h',
    'atof': 'stdlib.h',
    'abort': 'stdlib.h',
    'abs': 'stdlib.h',
    'getenv': 'stdlib.h',
    'system': 'stdlib.h',

    'printf': 'stdio.h',
    'fprintf': 'stdio.h',
    'sprintf': 'stdio.h',
    'scanf': 'stdio.h',
    'sscanf': 'stdio.h',
    'fopen': 'stdio.h',
    'fclose': 'stdio.h',
    'fread': 'stdio.h',
    'fwrite': 'stdio.h',
    'fgets': 'stdio.h',
    'fputs': 'stdio.h',
    'fgetc': 'stdio.h',
    'fputc': 'stdio.h',
    'perror': 'stdio.h',

    'strcmp': 'string.h',
    'strcpy': 'string.h',
    'strlen': 'string.h',
    'strcat': 'string.h',
    'strchr': 'string.h',
    'strrchr': 'string.h',
    'strstr': 'string.h',
    'strncmp': 'string.h',
    'strncpy': 'string.h',
    'memcpy': 'string.h',
    'memset': 'string.h',
    'memcmp': 'string.h',
    'bcopy': 'string.h',
    'bzero': 'string.h',
    'bcmp': 'string.h',

    'read': 'unistd.h',
    'write': 'unistd.h',
    'close': 'unistd.h',
    'open': 'unistd.h',
    'getpid': 'unistd.h',
    'getuid': 'unistd.h',
    'getgid': 'unistd.h',
    'fork': 'unistd.h',
    'execl': 'unistd.h',
    'execv': 'unistd.h',
    'chdir': 'unistd.h',
    'getcwd': 'unistd.h',
    'sleep': 'unistd.h',

    'socket': 'sys/socket.h',
    'bind': 'sys/socket.h',
    'listen': 'sys/socket.h',
    'accept': 'sys/socket.h',
    'connect': 'sys/socket.h',
    'send': 'sys/socket.h',
    'recv': 'sys/socket.h',
    'htons': 'arpa/inet.h',
    'htonl': 'arpa/inet.h',
    'ntohs': 'arpa/inet.h',
    'ntohl': 'arpa/inet.h',
}

def extract_function_name(error_message):
    """Extract function name from implicit function error message."""
    # Pattern: "call to undeclared library function 'funcname'"
    match = re.search(r"call to undeclared (?:library )?function '(\w+)'", error_message)
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

    # Check if already included
    if has_include(lines, header):
        return False, "Already included"

    # Find the best position to insert (after last #include)
    insert_pos = 0
    for i, line in enumerate(lines):
        if line.startswith('#include'):
            insert_pos = i + 1

    # If no includes found, look for first non-comment line after copyright
    if insert_pos == 0:
        in_comment = False
        for i, line in enumerate(lines):
            stripped = line.strip()
            if stripped.startswith('/*'):
                in_comment = True
            if in_comment and stripped.endswith('*/'):
                in_comment = False
                continue
            if not in_comment and stripped and not stripped.startswith('//') and not stripped.startswith('#ifndef') and not stripped.startswith('static char'):
                insert_pos = i
                break

    # Insert the header
    lines.insert(insert_pos, f'#include <{header}>\n')

    # Write back
    with open(file_path, 'w') as f:
        f.writelines(lines)

    return True, "Added"

def main():
    # Load the C17 database
    with open('logs/analysis/c17-compliance-post-kr-main/c17-database.json') as f:
        data = json.load(f)

    # Load files with 1 error
    with open('/tmp/low_error_files.json') as f:
        low_error_files = json.load(f)

    # Get implicit_function files with 1 error
    impl_files = [f for f in low_error_files
                  if f['error_count'] == 1 and 'implicit_function' in f['categories']]

    print(f"Found {len(impl_files)} files with 1 implicit_function error")
    print("=" * 80)

    fixed_count = 0
    skipped_count = 0

    for result in data['results']:
        if result['file'] not in [f['file'] for f in impl_files]:
            continue

        for error in result.get('errors', []):
            if error.get('severity') == 'error' and error.get('category') == 'implicit_function':
                func_name = extract_function_name(error['message'])
                if func_name and func_name in FUNCTION_TO_HEADER:
                    header = FUNCTION_TO_HEADER[func_name]
                    success, msg = add_header(result['file'], header)
                    if success:
                        print(f"✓ {result['file']:50s} + {header:20s} (for {func_name})")
                        fixed_count += 1
                    else:
                        print(f"○ {result['file']:50s} {msg}")
                        skipped_count += 1
                else:
                    print(f"? {result['file']:50s} Unknown function: {func_name}")
                    skipped_count += 1
                break  # Only process first error per file

    print("=" * 80)
    print(f"\nResults:")
    print(f"  Fixed:   {fixed_count}")
    print(f"  Skipped: {skipped_count}")
    print(f"  Total:   {len(impl_files)}")

if __name__ == '__main__':
    main()
