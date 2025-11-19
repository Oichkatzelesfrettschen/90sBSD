# 386BSD Build Issues and Solutions

## Ubuntu 24.04 Compatibility

### Common Issues and Solutions

#### 1. Missing BMake (BSD Make)
**Problem**: Legacy 386BSD code requires BSD Make, but Ubuntu ships with GNU Make.
**Solution**: 
```bash
sudo apt-get install bmake
```

#### 2. Missing Documentation Tools
**Problem**: CMake build fails due to missing Doxygen/Sphinx.
**Solution**:
```bash
sudo apt-get install doxygen graphviz python3-sphinx
python3 -m pip install --user breathe sphinx-rtd-theme
```

#### 3. Cross-compilation Issues
**Problem**: Building for i386 targets on x86_64 systems.
**Solution**:
```bash
sudo apt-get install gcc-multilib libc6-dev-i386
```

### Quick Setup for Ubuntu 24.04

```bash
# Install all dependencies
sudo apt-get update
sudo apt-get install -y \
    build-essential bmake cmake doxygen graphviz \
    python3-sphinx python3-pip flex bison git \
    clang clang-tools gcc-multilib libc6-dev-i386

# Install Python documentation tools
python3 -m pip install --user breathe sphinx-rtd-theme

# Run automated troubleshooting
./scripts/build-troubleshoot.sh --full-check
```

### Build System Overview

This repository supports multiple build systems:

1. **CMake (Recommended for development)**
   - Modern build system
   - Handles documentation generation
   - Includes testing framework
   - Cross-platform compatibility

2. **BMake (Legacy 386BSD)**
   - Required for original 386BSD kernel/userland
   - BSD-style Makefiles
   - Historical compatibility

3. **GNU Make (Limited use)**
   - Top-level convenience targets
   - Profile-based builds (PROFILE=clang-elf)

### Container-based Development

For consistent builds across environments:

```bash
# Build development container
docker build -f .github/containers/Dockerfile.dev -t 386bsd-dev .

# Run development environment
docker run -it --rm -v $PWD:/workspace 386bsd-dev

# Or use Docker Compose
docker-compose up dev
```

### CI/CD Pipeline

The GitHub Actions workflow now includes:

- **Modern Build**: CMake-based builds with full dependency management
- **Legacy Build**: BMake builds with timeout protection
- **Container Build**: Isolated environment testing
- **Troubleshooting**: Diagnostic information collection

### Troubleshooting Tools

Use the provided troubleshooting script:

```bash
# Check system compatibility
./scripts/build-troubleshoot.sh --check-tools

# Install missing dependencies
./scripts/build-troubleshoot.sh --install-deps

# Test build systems
./scripts/build-troubleshoot.sh --test-cmake
./scripts/build-troubleshoot.sh --test-bmake

# Complete diagnostic
./scripts/build-troubleshoot.sh --full-check
```

### Development Workflow

1. **Clone and setup**:
   ```bash
   git clone https://github.com/Oichkatzelesfrettschen/386bsd.git
   cd 386bsd
   ./scripts/build-troubleshoot.sh --install-deps
   ```

2. **Modern development** (recommended):
   ```bash
   mkdir build && cd build
   cmake .. -DBUILD_DOCS=ON -DBUILD_TESTS=ON
   make -j$(nproc)
   ```

3. **Legacy compatibility testing**:
   ```bash
   cd usr/src
   bmake clean
   bmake -n  # dry run to check for issues
   ```

4. **Documentation**:
   ```bash
   cd build
   make docs
   # Or serve locally: docker-compose up docs
   ```

### Known Limitations

- Legacy BMake builds may not complete on modern systems
- Some 386BSD-specific tooling requires additional setup
- Cross-compilation targets need specific toolchain configuration

### Getting Help

1. Run `./scripts/build-troubleshoot.sh --report` for diagnostic information
2. Check CI/CD logs for specific error patterns
3. Use the container environment for isolated testing