#!/usr/bin/env bash
# Automated header guard addition for 386BSD modernization
# Adds include guards to C header files that don't have them

set -euo pipefail

# Configuration
SRCDIR="${SRCDIR:-/home/user/386bsd/usr/src}"
LOGDIR="${LOGDIR:-/home/user/386bsd/logs/analysis}"
DRY_RUN="${DRY_RUN:-0}"

# Colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Create log directory
mkdir -p "$LOGDIR"

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOGFILE="$LOGDIR/add-header-guards-$TIMESTAMP.log"

echo -e "${BLUE}🛡️  386BSD Header Guard Addition Tool${NC}"
echo -e "${BLUE}=====================================${NC}"
echo ""
echo "Source directory: $SRCDIR"
echo "Log file: $LOGFILE"
if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "${YELLOW}Mode: DRY RUN (no files will be modified)${NC}"
else
    echo -e "${GREEN}Mode: LIVE (files will be modified)${NC}"
fi
echo ""

# Function to check if a header file has include guards
has_include_guard() {
    local file="$1"

    # Look for #ifndef or #pragma once in first 10 lines
    head -10 "$file" | grep -qE "(#ifndef|#pragma\s+once)"
}

# Function to generate guard macro name from file path
generate_guard_name() {
    local file="$1"

    # Convert path to guard macro
    # Example: sys/types.h -> _SYS_TYPES_H_
    # Example: kernel/vm/vm_page.h -> _KERNEL_VM_VM_PAGE_H_

    local guard=$(echo "$file" | \
        sed 's|/|_|g' | \
        sed 's|\.h$||' | \
        tr '[:lower:]' '[:upper:]' | \
        tr '-' '_')

    echo "_${guard}_H_"
}

# Function to add include guards to a file
add_guards() {
    local file="$1"
    local guard="$2"

    if [ "$DRY_RUN" -eq 1 ]; then
        echo "  [DRY RUN] Would add guards: $guard"
        return
    fi

    # Create temporary file
    local tmpfile=$(mktemp)

    # Add header guard
    {
        echo "/*"
        echo " * Include guard added by add-header-guards.sh"
        echo " * Date: $(date +%Y-%m-%d)"
        echo " */"
        echo "#ifndef $guard"
        echo "#define $guard"
        echo ""
        cat "$file"
        echo ""
        echo "#endif /* $guard */"
    } > "$tmpfile"

    # Replace original file
    mv "$tmpfile" "$file"

    echo "  [✓] Added guard: $guard"
}

# Find all header files
echo -e "${BLUE}Finding header files...${NC}"

mapfile -t HEADER_FILES < <(find "$SRCDIR" -name "*.h" -type f \
    ! -path "*/obj/*" \
    ! -path "*/.git/*" \
    ! -path "*/groff/*" \
    | sort)

TOTAL_HEADERS=${#HEADER_FILES[@]}
echo "Found $TOTAL_HEADERS header files"
echo ""

# Process headers
echo -e "${BLUE}Checking for missing guards...${NC}"

MISSING_COUNT=0
PROCESSED_COUNT=0
SKIPPED_COUNT=0

for header in "${HEADER_FILES[@]}"; do
    REL_PATH="${header#$SRCDIR/}"

    # Check if already has guards
    if has_include_guard "$header"; then
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        continue
    fi

    # Generate guard name
    GUARD=$(generate_guard_name "$REL_PATH")

    echo -e "${YELLOW}[$((MISSING_COUNT + 1))] $REL_PATH${NC}"

    # Add guards
    add_guards "$header" "$GUARD"

    MISSING_COUNT=$((MISSING_COUNT + 1))
    PROCESSED_COUNT=$((PROCESSED_COUNT + 1))

    # Log to file
    echo "$REL_PATH -> $GUARD" >> "$LOGFILE"
done

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   Header Guard Addition Complete!     ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo "Statistics:"
echo "  Total headers found: $TOTAL_HEADERS"
echo "  Already had guards: $SKIPPED_COUNT"
echo "  Missing guards: $MISSING_COUNT"
echo "  Processed: $PROCESSED_COUNT"
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
    echo -e "${YELLOW}This was a dry run. Re-run without DRY_RUN=1 to apply changes.${NC}"
else
    echo -e "${GREEN}Headers updated successfully!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review changes: git diff usr/src/**/*.h"
    echo "  2. Test build: cd usr/src && bmake clean && bmake"
    echo "  3. Commit changes: git add -u && git commit -m 'Add include guards to headers'"
fi

echo ""
echo "Log saved to: $LOGFILE"

# Generate summary
SUMMARY_FILE="$LOGDIR/header-guards-summary-$TIMESTAMP.txt"
{
    echo "Header Guard Addition Summary"
    echo "============================="
    echo "Date: $(date)"
    echo "Mode: $([ "$DRY_RUN" -eq 1 ] && echo "DRY RUN" || echo "LIVE")"
    echo ""
    echo "Total headers: $TOTAL_HEADERS"
    echo "Already had guards: $SKIPPED_COUNT ($(( SKIPPED_COUNT * 100 / TOTAL_HEADERS ))%)"
    echo "Missing guards: $MISSING_COUNT ($(( MISSING_COUNT * 100 / TOTAL_HEADERS ))%)"
    echo "Processed: $PROCESSED_COUNT"
    echo ""
    if [ "$DRY_RUN" -eq 0 ]; then
        echo "Files modified: See $LOGFILE"
    fi
} > "$SUMMARY_FILE"

echo "Summary: $SUMMARY_FILE"

# Exit with status based on whether headers needed guards
if [ "$MISSING_COUNT" -gt 0 ]; then
    exit 1
else
    exit 0
fi
