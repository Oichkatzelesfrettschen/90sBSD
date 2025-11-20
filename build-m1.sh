#!/bin/bash
# build-m1.sh - Optimized build script for Apple Silicon M1
# Supports multiple build strategies for maximum performance

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
KERNEL_DIR="usr/src/kernel"
BUILD_DIR="build"
IMAGE_NAME="386bsd-dev"

# Functions
print_usage() {
    cat << EOF
${BLUE}386BSD Build Script for Apple Silicon M1${NC}

Usage: $0 [MODE] [OPTIONS]

${YELLOW}Build Modes:${NC}
  native      - Fast cross-compilation using macOS native clang
  rosetta     - Docker + Rosetta 2 (recommended for full builds)
  docker      - Docker with QEMU (slow, not recommended)
  test        - Boot kernel in QEMU (testing only)
  benchmark   - Compare performance of all methods

${YELLOW}Options:${NC}
  -h, --help     Show this help message
  -c, --clean    Clean build artifacts first
  -v, --verbose  Verbose output

${YELLOW}Examples:${NC}
  $0 native           # Quick compile with macOS tools
  $0 rosetta          # Full build with Rosetta 2
  $0 test             # Test kernel in QEMU
  $0 benchmark        # Compare all build methods

${YELLOW}Performance Guide:${NC}
  native   - ~30s  (fastest, for quick iteration)
  rosetta  - ~45s  (recommended for full builds)
  docker   - ~5min (slow, avoid if possible)

EOF
}

check_prerequisites() {
    local mode=$1

    case "$mode" in
        native)
            if ! command -v clang &> /dev/null; then
                echo -e "${RED}Error: clang not found. Install Xcode Command Line Tools:${NC}"
                echo "  xcode-select --install"
                exit 1
            fi
            ;;
        rosetta|docker)
            if ! command -v docker &> /dev/null; then
                echo -e "${RED}Error: Docker not found. Install with:${NC}"
                echo "  brew install colima docker"
                echo "  colima start --arch x86_64 --vz-rosetta --cpu 4 --memory 8"
                exit 1
            fi
            ;;
        test)
            if ! command -v qemu-system-i386 &> /dev/null; then
                echo -e "${RED}Error: QEMU not found. Install with:${NC}"
                echo "  brew install qemu"
                exit 1
            fi
            ;;
    esac
}

clean_build() {
    echo -e "${YELLOW}Cleaning build artifacts...${NC}"
    rm -rf "$BUILD_DIR"/*.o "$BUILD_DIR"/*.elf 2>/dev/null || true
    echo -e "${GREEN}Clean complete${NC}"
}

build_native() {
    echo -e "${BLUE}Building with native macOS toolchain...${NC}"
    echo -e "${YELLOW}Architecture: ARM64 → i386 cross-compilation${NC}"
    echo -e "${YELLOW}Using BSD Makefile infrastructure${NC}"

    local start_time=$(date +%s)

    # Build using the BSD kernel build system
    cd usr/src/kernel
    export S=$(pwd)
    export MACHINE=i386

    # Use stock configuration
    bmake -f config/stock.mk clean 2>/dev/null || true
    bmake -f config/stock.mk

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    cd ../../..
    echo -e "${GREEN}✓ Native BSD kernel build complete in ${duration}s${NC}"
    if [ -f usr/src/kernel/386bsd ]; then
        ls -lh usr/src/kernel/386bsd
        file usr/src/kernel/386bsd
    fi
}

build_rosetta() {
    echo -e "${BLUE}Building with Docker + Rosetta 2...${NC}"
    echo -e "${YELLOW}Platform: linux/amd64 (Rosetta 2 accelerated)${NC}"
    echo -e "${YELLOW}Using BSD Makefile infrastructure${NC}"

    # Check if Rosetta is available
    if docker info 2>/dev/null | grep -q "rosetta"; then
        echo -e "${GREEN}✓ Rosetta 2 detected${NC}"
    else
        echo -e "${YELLOW}⚠ Rosetta 2 not detected. Performance may be slower.${NC}"
        echo -e "  Enable in Docker Desktop or use Colima:"
        echo -e "  colima start --arch x86_64 --vz-rosetta --cpu 4 --memory 8"
    fi

    local start_time=$(date +%s)

    # Build container if needed
    if ! docker image inspect $IMAGE_NAME &>/dev/null; then
        echo -e "${YELLOW}Building Docker image (one-time setup)...${NC}"
        docker build -f .devcontainer/Dockerfile.rosetta -t $IMAGE_NAME .
    fi

    # Run BSD kernel build in Docker
    docker run --rm --platform linux/amd64 \
        -v "$(pwd):/workspace" \
        -w /workspace/usr/src/kernel \
        $IMAGE_NAME \
        bash -c "
            export S=\$(pwd)
            export MACHINE=i386
            bmake -f config/stock.mk clean 2>/dev/null || make -f config/stock.mk clean 2>/dev/null || true
            bmake -f config/stock.mk || make -f config/stock.mk
            if [ -f 386bsd ]; then
                ls -lh 386bsd
                file 386bsd
            fi
        "

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo -e "${GREEN}✓ Rosetta BSD kernel build complete in ${duration}s${NC}"
    if [ -f usr/src/kernel/386bsd ]; then
        ls -lh usr/src/kernel/386bsd
    fi
}

build_docker_qemu() {
    echo -e "${BLUE}Building with Docker + QEMU emulation...${NC}"
    echo -e "${RED}⚠ WARNING: This is slow (5-10x slower than Rosetta)${NC}"

    local start_time=$(date +%s)

    docker run --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        i386/debian:stable-slim \
        bash -c "
            apt-get update -qq && apt-get install -y -qq gcc make >/dev/null 2>&1
            gcc -m32 -march=i386 \
                -ffreestanding -fno-builtin -fno-stack-protector \
                -I./$KERNEL_DIR/include \
                -I./$KERNEL_DIR \
                -DKERNEL -Di386 \
                $KERNEL_DIR/boot/kernel_main.c -c -o /tmp/kernel_main.o
        "

    local end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo -e "${GREEN}✓ QEMU build complete in ${duration}s${NC}"
    echo -e "${YELLOW}  (Consider using 'rosetta' mode for 5x speedup)${NC}"
}

test_kernel() {
    echo -e "${BLUE}Testing BSD kernel in QEMU...${NC}"

    if [ ! -f "usr/src/kernel/386bsd" ]; then
        echo -e "${RED}Error: usr/src/kernel/386bsd not found${NC}"
        echo "Build the kernel first with: $0 rosetta"
        exit 1
    fi

    echo -e "${YELLOW}Kernel info:${NC}"
    file usr/src/kernel/386bsd
    ls -lh usr/src/kernel/386bsd

    echo -e "${YELLOW}Launching QEMU (Ctrl+C to exit)...${NC}"
    qemu-system-i386 \
        -kernel usr/src/kernel/386bsd \
        -m 128M \
        -serial stdio \
        -nographic
}

benchmark_all() {
    echo -e "${BLUE}Benchmarking all build methods...${NC}"
    echo ""

    clean_build

    echo -e "${YELLOW}=== Test 1: Native macOS ===${NC}"
    local native_start=$(date +%s)
    build_native >/dev/null 2>&1
    local native_end=$(date +%s)
    local native_time=$((native_end - native_start))

    clean_build

    echo -e "${YELLOW}=== Test 2: Docker + Rosetta 2 ===${NC}"
    local rosetta_start=$(date +%s)
    build_rosetta >/dev/null 2>&1
    local rosetta_end=$(date +%s)
    local rosetta_time=$((rosetta_end - rosetta_start))

    echo ""
    echo -e "${GREEN}=== Benchmark Results ===${NC}"
    echo -e "Native macOS:       ${native_time}s  (baseline)"
    echo -e "Docker + Rosetta:   ${rosetta_time}s  ($((rosetta_time * 100 / native_time))% of native)"
    echo ""
    echo -e "${BLUE}Recommendation:${NC}"

    if [ $rosetta_time -lt $((native_time * 2)) ]; then
        echo -e "  ${GREEN}✓ Rosetta 2 is working well! Use 'rosetta' mode for consistent builds.${NC}"
    else
        echo -e "  ${YELLOW}⚠ Rosetta seems slow. Check if it's enabled:${NC}"
        echo -e "    docker info | grep rosetta"
    fi
}

# Main script
MODE="${1:-}"
CLEAN=false
VERBOSE=false

# Parse options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            print_usage
            exit 0
            ;;
        -c|--clean)
            CLEAN=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            set -x
            shift
            ;;
        native|rosetta|docker|test|benchmark)
            MODE="$1"
            shift
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            print_usage
            exit 1
            ;;
    esac
done

# Show usage if no mode specified
if [ -z "$MODE" ]; then
    print_usage
    exit 1
fi

# Clean if requested
if [ "$CLEAN" = true ]; then
    clean_build
fi

# Check prerequisites
check_prerequisites "$MODE"

# Execute requested mode
case "$MODE" in
    native)
        build_native
        ;;
    rosetta)
        build_rosetta
        ;;
    docker)
        build_docker_qemu
        ;;
    test)
        test_kernel
        ;;
    benchmark)
        benchmark_all
        ;;
    *)
        echo -e "${RED}Invalid mode: $MODE${NC}"
        print_usage
        exit 1
        ;;
esac

echo -e "${GREEN}Done!${NC}"
