#!/bin/bash
#
# Fix Inline Assembly Syntax for C17 Compliance
# Converts 'asm' keyword to '__asm__' for C17 compatibility
#
# Usage: ./fix-inline-asm.sh [--dry-run] [--verbose]
#
# Author: 386BSD Modernization Team
# Date: 2025-11-19

set -euo pipefail

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=false
VERBOSE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--dry-run] [--verbose]"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Inline Assembly Syntax Fix Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Repository: ${REPO_ROOT}"
echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "LIVE")"
echo ""

# Find all files with 'asm' keyword
echo -e "${YELLOW}Scanning for files with 'asm' keyword...${NC}"

# Kernel headers
KERNEL_HEADERS=$(find "${REPO_ROOT}/usr/src/kernel/include" -name "*.h" -type f -exec grep -l '\basm\b' {} \; 2>/dev/null || true)

# C source files
C_SOURCES=$(find "${REPO_ROOT}/usr/src" -name "*.c" -type f -exec grep -l '\basm\b' {} \; 2>/dev/null | head -50 || true)

# Combine and count
ALL_FILES=$(echo -e "${KERNEL_HEADERS}\n${C_SOURCES}" | grep -v '^$' | sort -u)
TOTAL_COUNT=$(echo "$ALL_FILES" | grep -v '^$' | wc -l)

echo "Found ${TOTAL_COUNT} files to process"
echo ""

if [ $TOTAL_COUNT -eq 0 ]; then
    echo -e "${GREEN}No files need fixing!${NC}"
    exit 0
fi

# Show sample files
echo "Sample files to process:"
echo "$ALL_FILES" | head -10
if [ $TOTAL_COUNT -gt 10 ]; then
    echo "... and $((TOTAL_COUNT - 10)) more"
fi
echo ""

if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN MODE - No files will be modified${NC}"
    echo ""
fi

# Process each file
PROCESSED=0
MODIFIED=0
FAILED=0

echo -e "${YELLOW}Processing files...${NC}"
echo ""

while IFS= read -r file; do
    [ -z "$file" ] && continue

    ((PROCESSED++))

    relative_path="${file#${REPO_ROOT}/}"

    if [ "$VERBOSE" = true ]; then
        echo -n "[$PROCESSED/$TOTAL_COUNT] $relative_path ... "
    else
        echo -ne "\r[$PROCESSED/$TOTAL_COUNT] Processing...   "
    fi

    # Count occurrences before
    BEFORE_COUNT=$(grep -o '\basm\b' "$file" | wc -l || echo "0")

    if [ $BEFORE_COUNT -eq 0 ]; then
        [ "$VERBOSE" = true ] && echo "SKIP (no matches)"
        continue
    fi

    # Create backup
    if [ "$DRY_RUN" = false ]; then
        cp "$file" "${file}.bak"
    fi

    # Perform replacement
    if [ "$DRY_RUN" = false ]; then
        sed -i 's/\basm\b/__asm__/g' "$file"

        # Verify replacement
        AFTER_COUNT=$(grep -o '\basm\b' "$file" | wc -l || echo "0")

        if [ $AFTER_COUNT -eq 0 ]; then
            ((MODIFIED++))
            [ "$VERBOSE" = true ] && echo -e "${GREEN}OK${NC} (${BEFORE_COUNT} replacements)"
            # Remove backup on success
            rm "${file}.bak"
        else
            ((FAILED++))
            [ "$VERBOSE" = true ] && echo -e "${RED}PARTIAL${NC} (${BEFORE_COUNT} -> ${AFTER_COUNT})"
            # Restore from backup
            mv "${file}.bak" "$file"
        fi
    else
        ((MODIFIED++))
        [ "$VERBOSE" = true ] && echo "WOULD FIX (${BEFORE_COUNT} occurrences)"
    fi

done <<< "$ALL_FILES"

echo ""
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Files processed:  $PROCESSED"
echo "Files modified:   $MODIFIED"
echo "Files failed:     $FAILED"
echo ""

if [ "$DRY_RUN" = false ] && [ $MODIFIED -gt 0 ]; then
    echo -e "${GREEN}Success! ${MODIFIED} files updated.${NC}"
    echo ""
    echo "To verify changes:"
    echo "  git diff usr/src/kernel/include"
    echo ""
    echo "To revert if needed:"
    echo "  git checkout usr/src/kernel/include"
    echo ""
elif [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN complete. Run without --dry-run to apply changes.${NC}"
    echo ""
fi

exit 0
