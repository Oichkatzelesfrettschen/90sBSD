#!/bin/bash
# Ultimate 386BSD Dependency Installation Script
# Comprehensive dependency management for Ubuntu 24.04

set -euo pipefail

# Color output for better visibility
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Main installation function
install_dependencies() {
    log_info "Starting 386BSD build dependency installation..."
    
    # Update package lists
    log_info "Updating package lists..."
    sudo apt-get update
    
    # Core build tools
    log_info "Installing core build tools..."
    sudo apt-get install -y \
        build-essential \
        gcc-multilib \
        make \
        bmake \
        flex \
        bison \
        git \
        binutils-dev \
        elfutils \
        gdb \
        valgrind
    
    # Verification
    log_info "Verifying installations..."
    
    if command -v bmake >/dev/null 2>&1; then
        log_success "bmake: $(bmake -V _BMAKE_VERSION 2>/dev/null || echo 'version unknown')"
    else
        log_error "bmake installation failed"
        exit 1
    fi
    
    if command -v gcc >/dev/null 2>&1; then
        log_success "gcc: $(gcc --version | head -1)"
    else
        log_error "gcc installation failed"
        exit 1
    fi
    
    if command -v as >/dev/null 2>&1; then
        log_success "as: $(as --version | head -1)"
    else
        log_error "assembler installation failed"
        exit 1
    fi
    
    log_success "All dependencies installed successfully!"
}

# Architecture-specific setup
setup_cross_compilation() {
    log_info "Setting up cross-compilation environment..."
    
    # Ensure 32-bit libraries are available
    sudo dpkg --add-architecture i386
    sudo apt-get update
    sudo apt-get install -y libc6-dev:i386
    
    log_success "Cross-compilation environment ready"
}

# Diagnostic function
run_diagnostics() {
    log_info "Running system diagnostics..."
    
    echo "=== System Information ==="
    uname -a
    lsb_release -a
    
    echo "=== Build Tools ==="
    gcc --version | head -1
    as --version | head -1
    ld --version | head -1
    bmake -V _BMAKE_VERSION 2>/dev/null || echo "bmake version unknown"
    
    echo "=== Architecture Support ==="
    dpkg --print-foreign-architectures
    
    log_success "Diagnostics complete"
}

# Main execution
main() {
    case "${1:-install}" in
        "install")
            install_dependencies
            setup_cross_compilation
            ;;
        "diagnostics")
            run_diagnostics
            ;;
        "full")
            install_dependencies
            setup_cross_compilation
            run_diagnostics
            ;;
        *)
            echo "Usage: $0 [install|diagnostics|full]"
            exit 1
            ;;
    esac
}

main "$@"