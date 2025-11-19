#!/usr/bin/env python3
"""
Batch fix implicit function declarations for specific file lists.
Enhanced version of fix-implicit-functions.py with more comprehensive mapping.
"""

import re
import sys
import json
from pathlib import Path

# Comprehensive function name to header mapping
FUNCTION_TO_HEADER = {
    # stdlib.h
    'exit': 'stdlib.h',
    'malloc': 'stdlib.h',
    'free': 'stdlib.h',
    'calloc': 'stdlib.h',
    'realloc': 'stdlib.h',
    'atoi': 'stdlib.h',
    'atol': 'stdlib.h',
    'atof': 'stdlib.h',
    'abort': 'stdlib.h',
    'abs': 'stdlib.h',
    'labs': 'stdlib.h',
    'getenv': 'stdlib.h',
    'putenv': 'stdlib.h',
    'setenv': 'stdlib.h',
    'system': 'stdlib.h',
    'qsort': 'stdlib.h',
    'rand': 'stdlib.h',
    'srand': 'stdlib.h',

    # stdio.h
    'printf': 'stdio.h',
    'fprintf': 'stdio.h',
    'sprintf': 'stdio.h',
    'scanf': 'stdio.h',
    'sscanf': 'stdio.h',
    'fscanf': 'stdio.h',
    'fopen': 'stdio.h',
    'fclose': 'stdio.h',
    'fread': 'stdio.h',
    'fwrite': 'stdio.h',
    'fgets': 'stdio.h',
    'fputs': 'stdio.h',
    'fgetc': 'stdio.h',
    'fputc': 'stdio.h',
    'getchar': 'stdio.h',
    'putchar': 'stdio.h',
    'puts': 'stdio.h',
    'perror': 'stdio.h',
    'fflush': 'stdio.h',
    'feof': 'stdio.h',
    'ferror': 'stdio.h',
    'rewind': 'stdio.h',
    'fseek': 'stdio.h',
    'ftell': 'stdio.h',

    # string.h
    'strcmp': 'string.h',
    'strcpy': 'string.h',
    'strlen': 'string.h',
    'strcat': 'string.h',
    'strchr': 'string.h',
    'strrchr': 'string.h',
    'strstr': 'string.h',
    'strncmp': 'string.h',
    'strncpy': 'string.h',
    'strncat': 'string.h',
    'strdup': 'string.h',
    'memcpy': 'string.h',
    'memset': 'string.h',
    'memcmp': 'string.h',
    'memmove': 'string.h',
    'bcopy': 'string.h',
    'bzero': 'string.h',
    'bcmp': 'string.h',

    # unistd.h
    'read': 'unistd.h',
    'write': 'unistd.h',
    'close': 'unistd.h',
    'open': 'unistd.h',
    'lseek': 'unistd.h',
    'getpid': 'unistd.h',
    'getppid': 'unistd.h',
    'getuid': 'unistd.h',
    'geteuid': 'unistd.h',
    'getgid': 'unistd.h',
    'getegid': 'unistd.h',
    'fork': 'unistd.h',
    'execl': 'unistd.h',
    'execv': 'unistd.h',
    'execve': 'unistd.h',
    'chdir': 'unistd.h',
    'getcwd': 'unistd.h',
    'sleep': 'unistd.h',
    'usleep': 'unistd.h',
    'access': 'unistd.h',
    'unlink': 'unistd.h',
    'rmdir': 'unistd.h',
    'sync': 'unistd.h',
    'dup': 'unistd.h',
    'dup2': 'unistd.h',
    'pipe': 'unistd.h',
    'isatty': 'unistd.h',

    # sys/types.h
    'major': 'sys/types.h',
    'minor': 'sys/types.h',
    'makedev': 'sys/types.h',

    # sys/stat.h
    'chmod': 'sys/stat.h',
    'fchmod': 'sys/stat.h',
    'stat': 'sys/stat.h',
    'fstat': 'sys/stat.h',
    'lstat': 'sys/stat.h',
    'mkdir': 'sys/stat.h',
    'mkfifo': 'sys/stat.h',
    'umask': 'sys/stat.h',

    # sys/socket.h, netinet, arpa
    'socket': 'sys/socket.h',
    'bind': 'sys/socket.h',
    'listen': 'sys/socket.h',
    'accept': 'sys/socket.h',
    'connect': 'sys/socket.h',
    'send': 'sys/socket.h',
    'recv': 'sys/socket.h',
    'sendto': 'sys/socket.h',
    'recvfrom': 'sys/socket.h',
    'htons': 'arpa/inet.h',
    'htonl': 'arpa/inet.h',
    'ntohs': 'arpa/inet.h',
    'ntohl': 'arpa/inet.h',
    'inet_addr': 'arpa/inet.h',
    'inet_ntoa': 'arpa/inet.h',

    # time.h
    'time': 'time.h',
    'ctime': 'time.h',
    'localtime': 'time.h',
    'gmtime': 'time.h',
    'asctime': 'time.h',
    'strftime': 'time.h',

    # signal.h
    'signal': 'signal.h',
    'kill': 'signal.h',
    'raise': 'signal.h',
    'sigaction': 'signal.h',
    'sigprocmask': 'signal.h',

    # ctype.h
    'isalpha': 'ctype.h',
    'isdigit': 'ctype.h',
    'isalnum': 'ctype.h',
    'isspace': 'ctype.h',
    'isupper': 'ctype.h',
    'islower': 'ctype.h',
    'toupper': 'ctype.h',
    'tolower': 'ctype.h',

    # fcntl.h
    'fcntl': 'fcntl.h',
    'creat': 'fcntl.h',

    # pwd.h, grp.h
    'getpwnam': 'pwd.h',
    'getpwuid': 'pwd.h',
    'getgrnam': 'grp.h',
    'getgrgid': 'grp.h',
}

def extract_function_name(error_message):
    """Extract function name from implicit function error message."""
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

    if has_include(lines, header):
        return False, "Already included"

    # Find position after last #include
    insert_pos = 0
    for i, line in enumerate(lines):
        if line.startswith('#include'):
            insert_pos = i + 1

    # If no includes, find first line after copyright/comments
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

    lines.insert(insert_pos, f'#include <{header}>\n')

    with open(file_path, 'w') as f:
        f.writelines(lines)

    return True, "Added"

def fix_file(file_path, c17_data):
    """Fix all implicit function errors in a file."""
    # Find this file in C17 data
    file_data = None
    for result in c17_data['results']:
        if result['file'] == file_path:
            file_data = result
            break

    if not file_data:
        return 0, []

    headers_added = []
    unknown_functions = []

    for error in file_data.get('errors', []):
        if error.get('severity') == 'error' and error.get('category') == 'implicit_function':
            func_name = extract_function_name(error['message'])
            if func_name and func_name in FUNCTION_TO_HEADER:
                header = FUNCTION_TO_HEADER[func_name]
                success, msg = add_header(file_path, header)
                if success and header not in headers_added:
                    headers_added.append(header)
            elif func_name:
                unknown_functions.append(func_name)

    return len(headers_added), unknown_functions

def main():
    # Load file list from argument or stdin
    if len(sys.argv) > 1:
        with open(sys.argv[1]) as f:
            file_list = [line.strip() for line in f if line.strip()]
    else:
        print("Usage: fix-implicit-functions-batch.py <file_list>")
        print("  Where file_list contains one file path per line")
        sys.exit(1)

    # Load C17 database
    with open('logs/analysis/c17-compliance-post-day14-fixed/c17-database.json') as f:
        c17_data = json.load(f)

    print("=" * 80)
    print("BATCH FIXING IMPLICIT FUNCTION DECLARATIONS")
    print("=" * 80)
    print(f"\nProcessing {len(file_list)} files...")
    print()

    total_fixed = 0
    total_unknown = 0

    for file_path in file_list:
        headers_added_count, unknown_funcs = fix_file(file_path, c17_data)

        if headers_added_count > 0:
            print(f"✓ {file_path:60s} (+{headers_added_count} headers)")
            total_fixed += 1
        elif unknown_funcs:
            print(f"? {file_path:60s} Unknown: {', '.join(unknown_funcs[:3])}")
            total_unknown += 1
        else:
            print(f"○ {file_path:60s} (no changes needed)")

    print()
    print("=" * 80)
    print(f"RESULTS:")
    print(f"  Fixed:   {total_fixed:3d} files")
    print(f"  Unknown: {total_unknown:3d} files")
    print(f"  Total:   {len(file_list):3d} files")

if __name__ == '__main__':
    main()
