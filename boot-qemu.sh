#!/bin/bash
#
# 386BSD Kernel QEMU Boot Script
# Phase 7 Boot Testing
#
# This script boots the 386BSD kernel in QEMU for testing.
# Requires: qemu-system-i386
#
# Usage: ./boot-qemu.sh [options]
#   -d, --debug     Enable QEMU debug output
#   -g, --gdb       Enable GDB debugging (wait for GDB connection)
#   -s, --serial    Output to serial console only (no VGA)
#   -h, --help      Show this help message

set -e

KERNEL="build/kernel.elf"
MEMORY="128M"
DEBUG_FLAGS=""
GDB_FLAGS=""
SERIAL_ONLY=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d|--debug)
            DEBUG_FLAGS="-d int,cpu_reset"
            shift
            ;;
        -g|--gdb)
            GDB_FLAGS="-s -S"
            echo "GDB mode: Connect with: gdb build/kernel.elf -ex 'target remote :1234'"
            shift
            ;;
        -s|--serial)
            SERIAL_ONLY="-nographic"
            shift
            ;;
        -h|--help)
            echo "386BSD Kernel QEMU Boot Script"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -d, --debug     Enable QEMU debug output"
            echo "  -g, --gdb       Enable GDB debugging"
            echo "  -s, --serial    Serial console only (no VGA)"
            echo "  -h, --help      Show this help"
            echo ""
            echo "Example:"
            echo "  $0              # Normal boot with VGA display"
            echo "  $0 --debug      # Boot with debug output"
            echo "  $0 --gdb        # Boot and wait for GDB"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Check if QEMU is installed
if ! command -v qemu-system-i386 &> /dev/null; then
    echo "ERROR: qemu-system-i386 not found"
    echo ""
    echo "To install QEMU on Ubuntu/Debian:"
    echo "  sudo apt-get update"
    echo "  sudo apt-get install qemu-system-x86"
    echo ""
    echo "To install QEMU on Fedora/RHEL:"
    echo "  sudo dnf install qemu-system-x86"
    echo ""
    echo "To install QEMU on macOS:"
    echo "  brew install qemu"
    exit 1
fi

# Check if kernel exists
if [ ! -f "$KERNEL" ]; then
    echo "ERROR: Kernel not found: $KERNEL"
    echo "Please run: ./compile-kernel.sh all"
    exit 1
fi

echo "========================================="
echo "386BSD Kernel Boot Test (Phase 7)"
echo "========================================="
echo "Kernel: $KERNEL"
echo "Memory: $MEMORY"
echo "Debug:  ${DEBUG_FLAGS:-disabled}"
echo "GDB:    ${GDB_FLAGS:-disabled}"
echo "Serial: ${SERIAL_ONLY:-VGA + serial}"
echo "========================================="
echo ""
echo "Booting kernel..."
echo ""

# Boot the kernel with QEMU
# -kernel: Load kernel directly (Multiboot-compliant)
# -m: Memory size
# -serial stdio: Output serial port to stdout
# -no-reboot: Exit on reboot instead of rebooting
# -no-shutdown: Exit on shutdown instead of displaying "QEMU Monitor"

qemu-system-i386 \
    -kernel "$KERNEL" \
    -m "$MEMORY" \
    -serial stdio \
    -no-reboot \
    -no-shutdown \
    $DEBUG_FLAGS \
    $GDB_FLAGS \
    $SERIAL_ONLY

echo ""
echo "========================================="
echo "Kernel execution finished"
echo "========================================="
