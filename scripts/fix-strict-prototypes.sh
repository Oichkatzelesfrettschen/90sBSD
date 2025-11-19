#!/bin/bash
#
# Fix Strict Prototypes for C17 Compliance
# Converts 'func()' to 'func(void)' in function declarations/definitions
#
# Usage: ./fix-strict-prototypes.sh [--dry-run] [--verbose]
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
echo -e "${BLUE}Strict Prototypes Fix Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Repository: ${REPO_ROOT}"
echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "LIVE")"
echo ""

# Find all C source and header files
echo -e "${YELLOW}Scanning for C files...${NC}"

ALL_FILES=$(find "${REPO_ROOT}/usr/src" -type f \( -name "*.c" -o -name "*.h" \) 2>/dev/null | sort)
TOTAL_COUNT=$(echo "$ALL_FILES" | wc -l)

echo "Found ${TOTAL_COUNT} files to process"
echo ""

if [ $TOTAL_COUNT -eq 0 ]; then
    echo -e "${GREEN}No files found!${NC}"
    exit 0
fi

# Show sample files
echo "Sample files:"
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
TOTAL_REPLACEMENTS=0

echo -e "${YELLOW}Processing files...${NC}"
echo ""

while IFS= read -r file; do
    [ -z "$file" ] && continue

    ((PROCESSED++))

    relative_path="${file#${REPO_ROOT}/}"

    if [ "$VERBOSE" = true ]; then
        echo -n "[$PROCESSED/$TOTAL_COUNT] $relative_path ... "
    else
        if [ $((PROCESSED % 100)) -eq 0 ] || [ $PROCESSED -eq $TOTAL_COUNT ]; then
            echo -ne "\r[$PROCESSED/$TOTAL_COUNT] Processing... ($(( PROCESSED * 100 / TOTAL_COUNT ))%)   "
        fi
    fi

    # Count occurrences before
    BEFORE_COUNT=$(grep -c '\(\)$' "$file" 2>/dev/null || echo "0")

    if [ "$BEFORE_COUNT" -eq 0 ]; then
        [ "$VERBOSE" = true ] && echo "SKIP (no matches)"
        continue
    fi

    # Perform replacement
    if [ "$DRY_RUN" = false ]; then
        # Use perl for reliable in-place editing
        perl -i -pe 's/\(\)$/(void)/g' "$file"

        # Verify replacement
        AFTER_COUNT=$(grep -c '\(\)$' "$file" 2>/dev/null || echo "0")

        REPLACEMENTS=$((BEFORE_COUNT - AFTER_COUNT))
        TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + REPLACEMENTS))

        if [ $AFTER_COUNT -eq 0 ]; then
            ((MODIFIED++))
            [ "$VERBOSE" = true ] && echo -e "${GREEN}OK${NC} (${REPLACEMENTS} replacements)"
        else
            ((MODIFIED++))
            [ "$VERBOSE" = true ] && echo -e "${YELLOW}PARTIAL${NC} (${REPLACEMENTS} replacements, ${AFTER_COUNT} remaining)"
        fi
    else
        TOTAL_REPLACEMENTS=$((TOTAL_REPLACEMENTS + BEFORE_COUNT))
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
echo "Files processed:      $PROCESSED"
echo "Files modified:       $MODIFIED"
echo "Files failed:         $FAILED"
echo "Total replacements:   $TOTAL_REPLACEMENTS"
echo ""

if [ "$DRY_RUN" = false ] && [ $MODIFIED -gt 0 ]; then
    echo -e "${GREEN}Success! ${MODIFIED} files updated with ${TOTAL_REPLACEMENTS} replacements.${NC}"
    echo ""
    echo "Pattern applied: func() → func(void)"
    echo ""
    echo "To verify changes:"
    echo "  git diff usr/src | head -100"
    echo ""
    echo "To revert if needed:"
    echo "  git checkout usr/src"
    echo ""
elif [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN complete.${NC}"
    echo "Would fix ${TOTAL_REPLACEMENTS} occurrences in ${MODIFIED} files."
    echo ""
    echo "Run without --dry-run to apply changes."
    echo ""
fi

exit 0
