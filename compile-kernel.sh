#!/bin/bash
#
# Simple 386BSD Kernel Compilation Script
# Compiles kernel files to .o without full BMake infrastructure
#
# Usage: ./compile-kernel.sh [file.c]
#        ./compile-kernel.sh all      (compile all known-good files)

set -e

# Kernel source directory
KSRC="$PWD/usr/src/kernel"
BUILD_DIR="$PWD/build"

# Compiler flags for i386 kernel
CFLAGS="-m32 -march=i386"
CFLAGS="$CFLAGS -I$KSRC/include -I$KSRC/include/sys -I$KSRC -I$KSRC/vm"
CFLAGS="$CFLAGS -DKERNEL -Di386"
CFLAGS="$CFLAGS -ffreestanding -fno-builtin -fno-stack-protector"
CFLAGS="$CFLAGS -nostdinc -Wall"

# Create build directory
mkdir -p "$BUILD_DIR"

# Known compilable files (0 errors) - Phase 5 Day 3: 11 files!
GOOD_FILES=(
    "kern/config.c"
    "kern/lock.c"
    "kern/malloc.c"
    "kern/host.c"
    "kern/reboot.c"
    "vm/vm_init.c"
    "kern/subr/disksort.c"
    "kern/subr/nullop.c"
    "kern/subr/ring.c"
    "kern/subr/rlist.c"
    "kern/subr/ffs.c"
)

# Files with minor issues but may be useful
PARTIAL_FILES=(
    "kern/clock.c"
    "kern/cred.c"
    "kern/main.c"
)

compile_file() {
    local srcfile="$1"
    local basename=$(basename "$srcfile" .c)
    local objfile="$BUILD_DIR/${basename}.o"

    echo "Compiling: $srcfile"
    if gcc -c $CFLAGS "$KSRC/$srcfile" -o "$objfile" 2>&1 | tee "$BUILD_DIR/${basename}.log"; then
        local errors=$(grep -c "error:" "$BUILD_DIR/${basename}.log" 2>/dev/null || echo "0")
        local warnings=$(grep -c "warning:" "$BUILD_DIR/${basename}.log" 2>/dev/null || echo "0")

        if [ "$errors" -eq 0 ]; then
            echo "  ✓ SUCCESS: $objfile ($warnings warnings)"
            return 0
        else
            echo "  ✗ FAILED: $errors errors, $warnings warnings"
            return 1
        fi
    else
        echo "  ✗ COMPILATION FAILED"
        return 1
    fi
}

if [ "$1" == "all" ]; then
    echo "=== Compiling Known-Good Files ==="
    success=0
    total=0

    for file in "${GOOD_FILES[@]}"; do
        total=$((total + 1))
        if compile_file "$file"; then
            success=$((success + 1))
        fi
        echo ""
    done

    echo "==================================="
    echo "Results: $success/$total files compiled successfully"
    echo "Object files in: $BUILD_DIR/"

    if [ "$success" -eq "$total" ]; then
        echo "✓ ALL FILES COMPILED SUCCESSFULLY!"
        exit 0
    else
        echo "⚠ Some files failed to compile"
        exit 1
    fi

elif [ "$1" == "partial" ]; then
    echo "=== Attempting Partial Files (may have errors) ==="
    success=0
    total=0

    for file in "${PARTIAL_FILES[@]}"; do
        total=$((total + 1))
        compile_file "$file" || true
        echo ""
    done

    echo "==================================="
    echo "Partial compilation complete"
    ls -lh "$BUILD_DIR/"*.o 2>/dev/null || echo "No .o files generated"

elif [ -n "$1" ]; then
    # Compile specific file
    if [ ! -f "$KSRC/$1" ]; then
        echo "Error: File not found: $KSRC/$1"
        exit 1
    fi
    compile_file "$1"

else
    echo "Usage: $0 [file.c|all|partial]"
    echo ""
    echo "Examples:"
    echo "  $0 all              # Compile all known-good files"
    echo "  $0 partial          # Try compiling files with minor issues"
    echo "  $0 kern/config.c    # Compile specific file"
    echo ""
    echo "Known-good files (0 errors):"
    for f in "${GOOD_FILES[@]}"; do
        echo "  - $f"
    done
    exit 1
fi
