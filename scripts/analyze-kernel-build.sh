#!/bin/bash
#
# Kernel Build Analysis Script
# Analyzes the current state of kernel compilation and identifies missing components
#

set -e
set -u

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KERNEL_DIR="$REPO_ROOT/usr/src/kernel"
BUILD_LOG="$REPO_ROOT/kernel-build-analysis.log"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_section() { echo -e "\n${CYAN}=== $1 ===${NC}\n"; }

# Check if kernel directory exists
if [ ! -d "$KERNEL_DIR" ]; then
    log_error "Kernel directory not found: $KERNEL_DIR"
    exit 1
fi

cd "$KERNEL_DIR"

log_section "386BSD Kernel Build Analysis"

# 1. Count kernel subsystems
log_info "Analyzing kernel subsystems..."
SUBSYSTEM_COUNT=$(find . -maxdepth 1 -type d ! -name '.' | wc -l)
echo "  Total subsystems: $SUBSYSTEM_COUNT"

# List all subsystems
echo "  Subsystems found:"
find . -maxdepth 1 -type d ! -name '.' -exec basename {} \; | sort | while read -r dir; do
    file_count=$(find "$dir" -name "*.c" -o -name "*.S" | wc -l)
    echo "    - $dir ($file_count source files)"
done

# 2. Count source files
log_section "Source File Statistics"
C_FILES=$(find . -name "*.c" | wc -l)
ASM_FILES=$(find . -name "*.S" -o -name "*.s" | wc -l)
HEADER_FILES=$(find . -name "*.h" | wc -l)

echo "  C source files:     $C_FILES"
echo "  Assembly files:     $ASM_FILES"
echo "  Header files:       $HEADER_FILES"
echo "  Total source files: $((C_FILES + ASM_FILES))"

# 3. Test compilation with make (GNU make)
log_section "Testing Build with GNU Make"

if [ -f Makefile ]; then
    log_info "Makefile found, attempting build..."

    # Try make clean
    log_info "Running: make clean"
    if make clean 2>&1 | tee "$BUILD_LOG.clean"; then
        log_success "make clean: OK"
    else
        log_warning "make clean: FAILED (this may be normal if bmake is required)"
    fi

    # Try make (dry run)
    log_info "Running: make -n (dry run)"
    if make -n 2>&1 | tee "$BUILD_LOG.dryrun"; then
        log_success "make -n: OK"
    else
        log_warning "make -n: FAILED"
    fi
else
    log_warning "No Makefile found in $KERNEL_DIR"
fi

# 4. Check for machine symlink
log_section "Checking Architecture Configuration"

if [ -L "machine" ]; then
    MACHINE_TARGET=$(readlink machine)
    log_success "machine symlink exists -> $MACHINE_TARGET"
elif [ -d "machine" ]; then
    log_warning "machine exists as directory (should be symlink)"
else
    log_error "machine symlink missing (required for i386 builds)"
    log_info "Creating machine symlink..."
    if [ -d "include/i386" ]; then
        ln -s include/i386 machine
        log_success "Created: machine -> include/i386"
    elif [ -d "i386/include" ]; then
        ln -s i386/include machine
        log_success "Created: machine -> i386/include"
    else
        log_error "Could not find i386 include directory"
    fi
fi

# 5. Analyze header dependencies
log_section "Analyzing Header Dependencies"

log_info "Checking critical kernel headers..."

CRITICAL_HEADERS=(
    "sys/types.h"
    "sys/param.h"
    "sys/systm.h"
    "sys/kernel.h"
    "sys/proc.h"
    "machine/cpu.h"
    "machine/psl.h"
    "vm/vm.h"
)

MISSING_HEADERS=()

for header in "${CRITICAL_HEADERS[@]}"; do
    if [ -f "$header" ] || [ -f "include/$header" ]; then
        echo "  ✓ $header"
    else
        echo "  ✗ $header (MISSING)"
        MISSING_HEADERS+=("$header")
    fi
done

if [ ${#MISSING_HEADERS[@]} -gt 0 ]; then
    log_warning "Missing ${#MISSING_HEADERS[@]} critical headers"
fi

# 6. Check for common compilation issues
log_section "Checking for Common Issues"

log_info "Searching for potential compilation problems..."

# Check for K&R style function definitions
KR_FUNCTIONS=$(grep -r "^[a-zA-Z_][a-zA-Z0-9_]*(" . --include="*.c" 2>/dev/null | wc -l || echo "0")
if [ "$KR_FUNCTIONS" -gt 0 ]; then
    log_warning "Found ~$KR_FUNCTIONS potential K&R style function definitions"
fi

# Check for implicit declarations
IMPLICIT_DECLS=$(grep -r "^\s*[a-z_][a-z0-9_]*\s*(" . --include="*.c" | grep -v "^.*\/\*" | wc -l || echo "0")

# Check for old-style casts
OLD_CASTS=$(grep -r "([a-z_][a-z0-9_]*\s*)" . --include="*.c" 2>/dev/null | wc -l || echo "0")

# Check for assembly syntax issues
ASM_CONCAT=$(grep -r "/\*\*/" . --include="*.S" --include="*.h" 2>/dev/null | wc -l || echo "0")
if [ "$ASM_CONCAT" -gt 0 ]; then
    log_warning "Found $ASM_CONCAT instances of old token concatenation (/**/) - should be ##"
fi

# 7. Identify buildable vs non-buildable components
log_section "Identifying Buildable Components"

log_info "Testing individual subsystem compilation..."

BUILDABLE=0
NOT_BUILDABLE=0

echo "" > "$BUILD_LOG.components"

for dir in $(find . -maxdepth 1 -type d ! -name '.' -exec basename {} \;); do
    if [ -d "$dir" ]; then
        cd "$dir"

        # Check if there are C files
        if ls *.c >/dev/null 2>&1; then
            # Try to compile first C file
            FIRST_C=$(ls *.c | head -1)

            echo -n "  Testing $dir/$FIRST_C... "

            if gcc -c -I../include -I.. "$FIRST_C" -o /tmp/test.o 2>/dev/null; then
                echo -e "${GREEN}OK${NC}"
                BUILDABLE=$((BUILDABLE + 1))
                echo "OK: $dir/$FIRST_C" >> "$BUILD_LOG.components"
            else
                echo -e "${RED}FAILED${NC}"
                NOT_BUILDABLE=$((NOT_BUILDABLE + 1))
                echo "FAILED: $dir/$FIRST_C" >> "$BUILD_LOG.components"

                # Capture error
                gcc -c -I../include -I.. "$FIRST_C" -o /tmp/test.o 2>&1 | head -5 >> "$BUILD_LOG.components"
            fi

            rm -f /tmp/test.o
        fi

        cd ..
    fi
done

echo ""
log_info "Buildable:     $BUILDABLE subsystems"
log_warning "Not buildable: $NOT_BUILDABLE subsystems"

# 8. Generate report
log_section "Generating Report"

REPORT_FILE="$REPO_ROOT/KERNEL_BUILD_REPORT.md"

cat > "$REPORT_FILE" <<EOF
# 386BSD Kernel Build Analysis Report

**Generated**: $(date)
**Kernel Directory**: $KERNEL_DIR

---

## Summary

- **Subsystems**: $SUBSYSTEM_COUNT
- **C Source Files**: $C_FILES
- **Assembly Files**: $ASM_FILES
- **Header Files**: $HEADER_FILES
- **Buildable Subsystems**: $BUILDABLE
- **Failed Subsystems**: $NOT_BUILDABLE

---

## Architecture Configuration

EOF

if [ -L "machine" ]; then
    echo "- ✓ machine symlink: \`$(readlink machine)\`" >> "$REPORT_FILE"
else
    echo "- ✗ machine symlink: MISSING" >> "$REPORT_FILE"
fi

cat >> "$REPORT_FILE" <<EOF

---

## Critical Headers

EOF

for header in "${CRITICAL_HEADERS[@]}"; do
    if [ -f "$header" ] || [ -f "include/$header" ]; then
        echo "- ✓ \`$header\`" >> "$REPORT_FILE"
    else
        echo "- ✗ \`$header\` (MISSING)" >> "$REPORT_FILE"
    fi
done

if [ ${#MISSING_HEADERS[@]} -gt 0 ]; then
    cat >> "$REPORT_FILE" <<EOF

### Missing Headers

These headers need to be imported from 4.4BSD-Lite2:

EOF

    for header in "${MISSING_HEADERS[@]}"; do
        echo "- \`$header\`" >> "$REPORT_FILE"
    done
fi

cat >> "$REPORT_FILE" <<EOF

---

## Potential Issues

- K&R style functions: ~$KR_FUNCTIONS
- Old token concatenation (/**/): $ASM_CONCAT files
- Requires manual review and fixes

---

## Component Build Status

See detailed component analysis in: \`kernel-build-analysis.log.components\`

### Quick Stats

- Successful: $BUILDABLE subsystems
- Failed: $NOT_BUILDABLE subsystems

---

## Next Steps

### Immediate (Phase 5)

1. Fix missing headers:
   \`\`\`bash
   ./scripts/import-from-bsd.sh ../bsd-sources/4.4BSD-Lite2 \\
       usr/src/sys/sys \\
       usr/src/include/sys
   \`\`\`

2. Fix machine symlink if missing:
   \`\`\`bash
   cd usr/src/kernel
   ln -s include/i386 machine  # or i386/include
   \`\`\`

3. Import missing kernel components from 4.4BSD-Lite2

4. Attempt full kernel build:
   \`\`\`bash
   cd usr/src/kernel
   make clean
   make depend
   make all
   \`\`\`

### Import Sources

| Component | Source | Priority |
|-----------|--------|----------|
| Missing headers | 4.4BSD-Lite2/usr/src/sys/sys | HIGH |
| Bootloader | 4.4BSD-Lite2/usr/src/sys/i386/boot | HIGH |
| Missing drivers | 4.4BSD-Lite2/usr/src/sys/i386/isa | MEDIUM |
| Init system | 4.4BSD-Lite2/usr/src/sbin/init | HIGH |

---

**Report saved to**: $REPORT_FILE
EOF

log_success "Report generated: $REPORT_FILE"
log_info "Build logs saved to: $BUILD_LOG.*"

# 9. Summary
log_section "Analysis Complete"

echo "Key findings:"
echo "  • Kernel has $SUBSYSTEM_COUNT subsystems with $C_FILES C files"
echo "  • $BUILDABLE subsystems compile successfully"
echo "  • $NOT_BUILDABLE subsystems need fixes"
if [ ${#MISSING_HEADERS[@]} -gt 0 ]; then
    echo "  • ${#MISSING_HEADERS[@]} critical headers are missing"
fi
echo ""
echo "Next: Review $REPORT_FILE for detailed analysis"
echo ""
