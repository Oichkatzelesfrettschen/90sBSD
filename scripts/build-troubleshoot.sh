#!/bin/bash
# build-troubleshoot.sh - Comprehensive build troubleshooting script for 386BSD
# This script helps diagnose and resolve build issues on Ubuntu 24.04

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Check if we're on Ubuntu 24.04
check_ubuntu_version() {
    log "Checking Ubuntu version..."
    if [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        if [ "$DISTRIB_RELEASE" = "24.04" ]; then
            success "Running on Ubuntu 24.04 LTS"
        else
            warning "Running on Ubuntu $DISTRIB_RELEASE (this script is optimized for 24.04)"
        fi
    else
        warning "Could not determine Ubuntu version"
    fi
}

# Install dependencies
install_dependencies() {
    log "Installing build dependencies..."
    
    local packages=(
        build-essential
        bmake
        cmake
        doxygen
        graphviz
        python3-sphinx
        python3-pip
        flex
        bison
        git
        clang
        clang-tools
        clang-tidy
        clang-format
    )
    
    # Check if running as root or with sudo
    local install_cmd="apt-get"
    if [ "$EUID" -ne 0 ]; then
        install_cmd="sudo apt-get"
    fi
    
    $install_cmd update
    $install_cmd install -y "${packages[@]}"
    
    # Install Python packages
    python3 -m pip install --user breathe sphinx-rtd-theme
}

# Check tool availability
check_tools() {
    log "Checking tool availability..."
    
    local tools=(
        "bmake:BSD Make"
        "cmake:CMake"
        "doxygen:Doxygen"
        "sphinx-build:Sphinx"
        "clang:Clang"
        "clang-tidy:Clang-Tidy"
        "flex:Flex"
        "bison:Bison"
    )
    
    local missing_tools=()
    
    for tool_spec in "${tools[@]}"; do
        IFS=':' read -r tool_name tool_desc <<< "$tool_spec"
        if command -v "$tool_name" >/dev/null 2>&1; then
            success "$tool_desc found: $(command -v "$tool_name")"
        else
            error "$tool_desc not found"
            missing_tools+=("$tool_name")
        fi
    done
    
    if [ ${#missing_tools[@]} -eq 0 ]; then
        success "All required tools are available"
        return 0
    else
        error "Missing tools: ${missing_tools[*]}"
        return 1
    fi
}

# Test CMake build
test_cmake_build() {
    log "Testing CMake build system..."
    
    if [ ! -f "CMakeLists.txt" ]; then
        error "CMakeLists.txt not found. Please run this script from the repository root."
        return 1
    fi
    
    # Clean previous build
    rm -rf build-test
    mkdir -p build-test
    cd build-test
    
    # Configure
    log "Configuring CMake..."
    if cmake .. -DBUILD_DOCS=ON -DBUILD_TESTS=ON; then
        success "CMake configuration successful"
    else
        error "CMake configuration failed"
        cd ..
        return 1
    fi
    
    # Build
    log "Building with CMake..."
    if make -j"$(nproc)"; then
        success "CMake build successful"
    else
        error "CMake build failed"
        cd ..
        return 1
    fi
    
    cd ..
    success "CMake build test completed successfully"
}

# Test BMake build
test_bmake_build() {
    log "Testing BMake build system..."
    
    if [ ! -f "usr/src/Makefile" ]; then
        error "usr/src/Makefile not found"
        return 1
    fi
    
    cd usr/src
    
    # Test a dry run first
    log "Testing BMake dry run..."
    if timeout 60 bmake -n >/dev/null 2>&1; then
        success "BMake dry run successful"
    else
        warning "BMake dry run had issues (this may be expected for legacy code)"
    fi
    
    cd ../..
    log "BMake build test completed"
}

# Generate build report
generate_report() {
    log "Generating build troubleshooting report..."
    
    local report_file="build-troubleshoot-report.md"
    
    cat > "$report_file" << EOF
# 386BSD Build Troubleshooting Report

Generated on: $(date)
System: $(uname -a)

## System Information
$(lsb_release -a 2>/dev/null || echo "OS information not available")

## Tool Versions
EOF
    
    local tools=("bmake" "cmake" "doxygen" "sphinx-build" "clang" "flex" "bison")
    
    for tool in "${tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "- $tool: $($tool --version 2>/dev/null | head -1 || echo "Version check failed")" >> "$report_file"
        else
            echo "- $tool: NOT FOUND" >> "$report_file"
        fi
    done
    
    cat >> "$report_file" << EOF

## Available Packages
$(apt list --installed 2>/dev/null | grep -E "(make|cmake|doxygen|sphinx|flex|bison)" | head -20)

## Repository Structure Check
\`\`\`
$(ls -la usr/src/ | head -10)
\`\`\`

## Recommendations
1. Ensure all dependencies are installed with: \`$0 --install-deps\`
2. Use the CMake build system for modern development: \`mkdir build && cd build && cmake .. && make\`
3. The legacy BMake system may require additional configuration for modern systems
4. Consider using the provided Docker container for consistent builds

EOF
    
    success "Report generated: $report_file"
}

# Main function
main() {
    log "Starting 386BSD build troubleshooting..."
    
    case "${1:-help}" in
        --install-deps)
            install_dependencies
            ;;
        --check-tools)
            check_tools
            ;;
        --test-cmake)
            test_cmake_build
            ;;
        --test-bmake)
            test_bmake_build
            ;;
        --full-check)
            check_ubuntu_version
            install_dependencies
            check_tools
            test_cmake_build
            test_bmake_build
            generate_report
            ;;
        --report)
            generate_report
            ;;
        help|--help)
            cat << EOF
Usage: $0 [OPTION]

Options:
  --install-deps    Install required build dependencies
  --check-tools     Check availability of build tools
  --test-cmake      Test CMake build system
  --test-bmake      Test BMake build system
  --full-check      Run complete troubleshooting suite
  --report          Generate troubleshooting report
  help, --help      Show this help message

Examples:
  $0 --full-check   # Complete troubleshooting
  $0 --install-deps # Just install dependencies
  $0 --test-cmake   # Test modern build system
EOF
            ;;
        *)
            error "Unknown option: $1"
            exit 1
            ;;
    esac
}

main "$@"