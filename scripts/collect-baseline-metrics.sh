#!/usr/bin/env bash
# Collect baseline metrics for 386BSD modernization project

set -euo pipefail

# Configuration
REPODIR="${REPODIR:-/home/user/386bsd}"
SRCDIR="${SRCDIR:-$REPODIR/usr/src}"
METRICSDIR="${METRICSDIR:-$REPODIR/logs/metrics}"

DATE=$(date +%Y%m%d)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

# Create metrics directory
mkdir -p "$METRICSDIR"

echo -e "${BLUE}📊 386BSD Baseline Metrics Collection${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo "Repository: $REPODIR"
echo "Source: $SRCDIR"
echo "Metrics output: $METRICSDIR"
echo "Timestamp: $TIMESTAMP"
echo ""

# Metric 1: Lines of code
echo -e "${BLUE}[1/8] Counting lines of code...${NC}"

if command -v cloc >/dev/null 2>&1; then
    cloc "$SRCDIR" \
        --csv \
        --out="$METRICSDIR/loc-$DATE.csv" \
        --quiet

    cloc "$SRCDIR" \
        --by-file \
        --csv \
        --out="$METRICSDIR/loc-by-file-$DATE.csv" \
        --quiet

    # Extract summary
    TOTAL_LOC=$(tail -1 "$METRICSDIR/loc-$DATE.csv" | cut -d, -f5)
    C_LOC=$(grep "^C," "$METRICSDIR/loc-$DATE.csv" | cut -d, -f5 || echo "0")

    echo "   Total LOC: $TOTAL_LOC"
    echo "   C LOC: $C_LOC"
else
    echo "   ⚠️  cloc not installed, using basic counts"

    find "$SRCDIR" -name "*.c" -exec wc -l {} + | \
        tail -1 > "$METRICSDIR/c-loc-basic-$DATE.txt"

    TOTAL_LOC=$(cat "$METRICSDIR/c-loc-basic-$DATE.txt" | awk '{print $1}')
    echo "   Estimated C LOC: $TOTAL_LOC"
fi

# Metric 2: File counts by type
echo -e "${BLUE}[2/8] Counting files by type...${NC}"

{
    echo "File Type Counts"
    echo "================"
    echo "C files: $(find "$SRCDIR" -name "*.c" | wc -l)"
    echo "Header files: $(find "$SRCDIR" -name "*.h" | wc -l)"
    echo "Assembly files: $(find "$SRCDIR" -name "*.s" -o -name "*.S" | wc -l)"
    echo "Makefiles: $(find "$SRCDIR" -name "Makefile" -o -name "*.mk" | wc -l)"
    echo "Total source files: $(find "$SRCDIR" -type f | wc -l)"
} | tee "$METRICSDIR/file-counts-$DATE.txt"

# Metric 3: TODO/FIXME counts
echo -e "${BLUE}[3/8] Counting TODO/FIXME markers...${NC}"

{
    echo "TODO/FIXME Counts"
    echo "================="
    for marker in TODO FIXME XXX HACK BUG DEPRECATED; do
        count=$(grep -r "$marker" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l || echo "0")
        echo "$marker: $count"
    done
} | tee "$METRICSDIR/todo-count-$DATE.txt"

# Metric 4: C standard usage detection
echo -e "${BLUE}[4/8] Detecting C standard usage...${NC}"

{
    echo "C Standard Feature Detection"
    echo "============================"

    # C89/C90 features
    echo "// comments: $(grep -r "//" "$SRCDIR" --include="*.c" 2>/dev/null | wc -l)"

    # C99 features
    echo "C99 stdint.h: $(grep -r "#include <stdint.h>" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l)"
    echo "C99 stdbool.h: $(grep -r "#include <stdbool.h>" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l)"
    echo "C99 inline: $(grep -r "\binline\b" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l)"

    # C11 features
    echo "C11 stdatomic.h: $(grep -r "#include <stdatomic.h>" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l)"
    echo "C11 _Atomic: $(grep -r "\b_Atomic\b" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l)"
    echo "C11 _Static_assert: $(grep -r "\b_Static_assert\b" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l)"
    echo "C11 _Generic: $(grep -r "\b_Generic\b" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l)"

    # K&R style detection
    echo "K&R function defs (approx): $(find "$SRCDIR" -name "*.c" -exec grep -l "^[a-zA-Z_][a-zA-Z0-9_]*([^)]*)\$" {} \; 2>/dev/null | wc -l)"

} | tee "$METRICSDIR/c-standard-usage-$DATE.txt"

# Metric 5: Header analysis
echo -e "${BLUE}[5/8] Analyzing header files...${NC}"

{
    echo "Header File Analysis"
    echo "===================="

    TOTAL_HEADERS=$(find "$SRCDIR" -name "*.h" | wc -l)
    echo "Total headers: $TOTAL_HEADERS"

    # Headers with include guards
    HEADERS_WITH_GUARDS=$(find "$SRCDIR" -name "*.h" -exec grep -l "#ifndef.*_H" {} \; 2>/dev/null | wc -l)
    echo "Headers with guards: $HEADERS_WITH_GUARDS"

    # Calculate percentage
    if [ "$TOTAL_HEADERS" -gt 0 ]; then
        GUARD_PERCENT=$((HEADERS_WITH_GUARDS * 100 / TOTAL_HEADERS))
        echo "Guard coverage: $GUARD_PERCENT%"
    fi

    # System headers included
    echo ""
    echo "Most included system headers:"
    grep -rh "#include <" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | \
        sed 's/.*#include <//' | sed 's/>.*//' | \
        sort | uniq -c | sort -rn | head -20

} | tee "$METRICSDIR/header-analysis-$DATE.txt"

# Metric 6: Function analysis
echo -e "${BLUE}[6/8] Analyzing function definitions...${NC}"

{
    echo "Function Analysis"
    echo "================="

    # Count functions (rough estimate)
    FUNC_COUNT=$(grep -r "^[a-zA-Z_][a-zA-Z0-9_]*\s*(" "$SRCDIR" --include="*.c" 2>/dev/null | wc -l)
    echo "Estimated function count: $FUNC_COUNT"

    # Static functions
    STATIC_FUNC=$(grep -r "^static.*(" "$SRCDIR" --include="*.c" 2>/dev/null | wc -l)
    echo "Static functions: $STATIC_FUNC"

    # Inline functions
    INLINE_FUNC=$(grep -r "^inline.*(" "$SRCDIR" --include="*.c" --include="*.h" 2>/dev/null | wc -l)
    echo "Inline functions: $INLINE_FUNC"

} | tee "$METRICSDIR/function-analysis-$DATE.txt"

# Metric 7: Build system analysis
echo -e "${BLUE}[7/8] Analyzing build system...${NC}"

{
    echo "Build System Analysis"
    echo "===================="

    echo "Makefiles: $(find "$REPODIR" -name "Makefile" | wc -l)"
    echo "*.mk files: $(find "$REPODIR" -name "*.mk" | wc -l)"
    echo "CMakeLists.txt: $(find "$REPODIR" -name "CMakeLists.txt" | wc -l)"

    # Check for bmake usage
    echo ""
    echo "Build system types detected:"
    [ -f "$REPODIR/mk/clang-elf.mk" ] && echo "  ✓ BMAKE (BSD Make) with Clang profile"
    [ -f "$REPODIR/CMakeLists.txt" ] && echo "  ✓ CMake"
    [ -f "$REPODIR/Makefile" ] && echo "  ✓ GNU/BSD Make"

} | tee "$METRICSDIR/build-system-$DATE.txt"

# Metric 8: Repository structure
echo -e "${BLUE}[8/8] Analyzing repository structure...${NC}"

{
    echo "Repository Structure"
    echo "===================="

    du -sh "$REPODIR"/{usr/src,bin,sbin,docs,scripts,mk} 2>/dev/null | \
        sort -hr

    echo ""
    echo "Top-level directories:"
    ls -d "$REPODIR"/*/ 2>/dev/null | wc -l

    echo ""
    echo "Documentation files:"
    find "$REPODIR" -maxdepth 1 -name "*.md" -o -name "*.TXT" | wc -l

} | tee "$METRICSDIR/repo-structure-$DATE.txt"

# Generate master summary
echo ""
echo -e "${BLUE}Generating master summary...${NC}"

SUMMARY_FILE="$METRICSDIR/baseline-summary-$DATE.txt"

{
    echo "=========================================="
    echo "386BSD Baseline Metrics Summary"
    echo "=========================================="
    echo "Date: $(date)"
    echo "Repository: $REPODIR"
    echo ""

    echo "--- Code Volume ---"
    echo "Total LOC: $TOTAL_LOC"
    echo "C LOC: ${C_LOC:-N/A}"
    echo "C files: $(find "$SRCDIR" -name "*.c" | wc -l)"
    echo "Header files: $(find "$SRCDIR" -name "*.h" | wc -l)"
    echo ""

    echo "--- Code Quality Indicators ---"
    cat "$METRICSDIR/todo-count-$DATE.txt"
    echo ""

    echo "--- C Standard Usage ---"
    cat "$METRICSDIR/c-standard-usage-$DATE.txt"
    echo ""

    echo "--- Build System ---"
    cat "$METRICSDIR/build-system-$DATE.txt"
    echo ""

    echo "=========================================="
    echo "Detailed metrics available in: $METRICSDIR"
    echo "=========================================="

} | tee "$SUMMARY_FILE"

# Create latest symlink
ln -sf "baseline-summary-$DATE.txt" "$METRICSDIR/baseline-summary-latest.txt"

echo ""
echo -e "${GREEN}✅ Metrics collection complete!${NC}"
echo ""
echo "Summary: $SUMMARY_FILE"
echo "View latest: $METRICSDIR/baseline-summary-latest.txt"
echo ""
echo "Next steps:"
echo "  1. Review metrics summary"
echo "  2. Run static analysis: ./scripts/static-analysis.sh"
echo "  3. Begin Phase 1 modernization tasks"
