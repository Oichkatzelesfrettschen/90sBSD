#!/usr/bin/env bash
# Static analysis orchestrator for 386BSD C17 modernization

set -euo pipefail

# Configuration
SRCDIR="${SRCDIR:-/home/user/386bsd/usr/src}"
LOGDIR="${LOGDIR:-/home/user/386bsd/logs/analysis}"
DATE=$(date +%Y%m%d-%H%M%S)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create log directory
mkdir -p "$LOGDIR"

echo -e "${BLUE}🔍 386BSD Static Analysis Suite${NC}"
echo -e "${BLUE}================================${NC}"
echo ""
echo "Source directory: $SRCDIR"
echo "Log directory: $LOGDIR"
echo "Timestamp: $DATE"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Track available tools
AVAILABLE_TOOLS=()
MISSING_TOOLS=()

# Check for required tools
for tool in clang-tidy cppcheck clang python3; do
    if command_exists "$tool"; then
        AVAILABLE_TOOLS+=("$tool")
    else
        MISSING_TOOLS+=("$tool")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: Missing tools: ${MISSING_TOOLS[*]}${NC}"
    echo "   Some analyses will be skipped."
    echo ""
fi

# Analysis 1: clang-tidy (C17 conformance)
if command_exists clang-tidy; then
    echo -e "${BLUE}[1/5] Running clang-tidy (C17 conformance checks)...${NC}"

    TIDY_LOG="$LOGDIR/clang-tidy-$DATE.log"
    TIDY_SUMMARY="$LOGDIR/clang-tidy-summary-$DATE.txt"

    # Find C files (exclude generated and third-party)
    find "$SRCDIR" -name "*.c" -type f \
        ! -path "*/obj/*" \
        ! -path "*/.git/*" \
        ! -path "*/groff/*" \
        > "$LOGDIR/c-files-$DATE.txt"

    FILE_COUNT=$(wc -l < "$LOGDIR/c-files-$DATE.txt")
    echo "   Analyzing $FILE_COUNT C files..."

    # Run clang-tidy with C17 checks
    cat "$LOGDIR/c-files-$DATE.txt" | \
        xargs -P "$(nproc)" -I {} \
        clang-tidy {} \
            -checks='modernize-*,readability-*,bugprone-*,clang-analyzer-*' \
            -- -std=c17 -m32 \
        2>&1 | tee "$TIDY_LOG" || true

    # Generate summary
    {
        echo "clang-tidy Analysis Summary"
        echo "==========================="
        echo ""
        echo "Total files: $FILE_COUNT"
        echo "Warnings:"
        grep "warning:" "$TIDY_LOG" | cut -d: -f4 | sort | uniq -c | sort -rn || echo "  None found"
        echo ""
        echo "Errors:"
        grep "error:" "$TIDY_LOG" | cut -d: -f4 | sort | uniq -c | sort -rn || echo "  None found"
    } > "$TIDY_SUMMARY"

    echo -e "   ${GREEN}✓${NC} Complete. Results in $TIDY_LOG"
else
    echo -e "${YELLOW}[1/5] Skipping clang-tidy (not installed)${NC}"
fi

# Analysis 2: cppcheck (additional static analysis)
if command_exists cppcheck; then
    echo -e "${BLUE}[2/5] Running cppcheck...${NC}"

    CPPCHECK_LOG="$LOGDIR/cppcheck-$DATE.log"

    cppcheck \
        --enable=all \
        --std=c11 \
        --suppress=missingIncludeSystem \
        --suppress=unusedFunction \
        --force \
        --quiet \
        "$SRCDIR" \
        2>&1 | tee "$CPPCHECK_LOG" || true

    # Count issues
    ISSUE_COUNT=$(grep -c ":" "$CPPCHECK_LOG" || echo "0")
    echo -e "   ${GREEN}✓${NC} Complete. Found $ISSUE_COUNT potential issues"
else
    echo -e "${YELLOW}[2/5] Skipping cppcheck (not installed)${NC}"
fi

# Analysis 3: Header dependency analysis
if command_exists python3; then
    echo -e "${BLUE}[3/5] Running header dependency analysis...${NC}"

    if [ -f "/home/user/386bsd/scripts/header-dependency-graph.py" ]; then
        python3 /home/user/386bsd/scripts/header-dependency-graph.py "$SRCDIR" \
            2>&1 | tee "$LOGDIR/header-deps-$DATE.log" || true
        echo -e "   ${GREEN}✓${NC} Complete"
    else
        echo -e "   ${YELLOW}⚠️  Script not found${NC}"
    fi
else
    echo -e "${YELLOW}[3/5] Skipping header analysis (python3 not installed)${NC}"
fi

# Analysis 4: K&R vs ANSI/C17 function detection
echo -e "${BLUE}[4/5] Detecting K&R-style function definitions...${NC}"

KR_LOG="$LOGDIR/kr-functions-$DATE.txt"

# Look for K&R style: function name followed by parameter declarations
# Pattern: function_name(param1, param2)\n<type declarations>
find "$SRCDIR" -name "*.c" -type f \
    ! -path "*/obj/*" \
    ! -path "*/.git/*" \
    -exec grep -l "^[a-zA-Z_][a-zA-Z0-9_]*([^)]*)\$" {} \; \
    > "$KR_LOG" || true

KR_COUNT=$(wc -l < "$KR_LOG")
echo -e "   Found $KR_COUNT files potentially with K&R functions"
echo -e "   ${GREEN}✓${NC} Results in $KR_LOG"

# Analysis 5: TODO/FIXME/XXX/HACK analysis
echo -e "${BLUE}[5/5] Analyzing TODO/FIXME markers...${NC}"

TODO_LOG="$LOGDIR/todos-$DATE.txt"
TODO_SUMMARY="$LOGDIR/todos-summary-$DATE.txt"

# Find all marker comments
grep -r "TODO\|FIXME\|XXX\|HACK\|BUG" "$SRCDIR" \
    --include="*.c" \
    --include="*.h" \
    2>/dev/null | tee "$TODO_LOG" || true

# Generate summary
{
    echo "TODO/FIXME Marker Summary"
    echo "========================="
    echo ""
    echo "Total markers:"
    wc -l "$TODO_LOG"
    echo ""
    echo "By type:"
    for marker in TODO FIXME XXX HACK BUG; do
        count=$(grep -c "$marker" "$TODO_LOG" || echo "0")
        echo "  $marker: $count"
    done
    echo ""
    echo "By subsystem:"
    cut -d: -f1 "$TODO_LOG" | \
        xargs -I {} dirname {} | \
        sort | uniq -c | sort -rn | head -20
} > "$TODO_SUMMARY"

cat "$TODO_SUMMARY"
echo ""

# Final summary
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Static Analysis Complete!           ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Results saved to: $LOGDIR"
echo ""
echo "Next steps:"
echo "  1. Review logs in $LOGDIR"
echo "  2. Prioritize issues for fixing"
echo "  3. Run 'scripts/collect-baseline-metrics.sh' for full metrics"
echo ""

# Generate master summary
MASTER_SUMMARY="$LOGDIR/analysis-master-summary-$DATE.txt"
{
    echo "386BSD Static Analysis Master Summary"
    echo "======================================"
    echo "Date: $(date)"
    echo ""
    echo "Available tools: ${AVAILABLE_TOOLS[*]}"
    if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
        echo "Missing tools: ${MISSING_TOOLS[*]}"
    fi
    echo ""
    echo "--- Analysis Results ---"
    echo ""

    if [ -f "$TIDY_SUMMARY" ]; then
        cat "$TIDY_SUMMARY"
        echo ""
    fi

    if [ -f "$CPPCHECK_LOG" ]; then
        echo "cppcheck issues: $(grep -c ":" "$CPPCHECK_LOG" || echo "0")"
        echo ""
    fi

    echo "K&R-style files: $KR_COUNT"
    echo ""

    cat "$TODO_SUMMARY"

} > "$MASTER_SUMMARY"

echo "Master summary: $MASTER_SUMMARY"
