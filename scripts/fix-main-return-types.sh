#!/bin/bash
#
# Fix main() Function Return Types
# Adds explicit "int" return type to main() functions missing it
#
# Usage: ./fix-main-return-types.sh [--dry-run] [--verbose]
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

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}main() Return Type Fix Tool${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Repository: ${REPO_ROOT}"
echo "Mode: $([ "$DRY_RUN" = true ] && echo "DRY RUN" || echo "LIVE")"
echo ""

# Find all C source files
echo -e "${YELLOW}Scanning for C files with main()...${NC}"

ALL_FILES=$(find "${REPO_ROOT}/usr/src" -type f -name "*.c" 2>/dev/null | sort)
TOTAL_COUNT=$(echo "$ALL_FILES" | wc -l)

echo "Found ${TOTAL_COUNT} C files to scan"
echo ""

PROCESSED=0
MODIFIED=0
TOTAL_FIXES=0

echo -e "${YELLOW}Processing files...${NC}"
echo ""

while IFS= read -r file; do
    [ -z "$file" ] && continue

    ((PROCESSED++))

    if [ $((PROCESSED % 100)) -eq 0 ] || [ $PROCESSED -eq $TOTAL_COUNT ]; then
        echo -ne "\r[$PROCESSED/$TOTAL_COUNT] Scanning... ($(( PROCESSED * 100 / TOTAL_COUNT ))%)   "
    fi

    # Check if file contains "main(" without preceding "int"
    if grep -q '^main(' "$file"; then
        relative_path="${file#${REPO_ROOT}/}"

        if [ "$VERBOSE" = true ]; then
            echo ""
            echo -n "  $relative_path ... "
        fi

        if [ "$DRY_RUN" = false ]; then
            # Add "int" before "main(" at start of line
            perl -i.bak -pe 's/^main\(/int\nmain(/' "$file"

            # Check if change was made
            if ! cmp -s "$file" "$file.bak"; then
                ((MODIFIED++))
                ((TOTAL_FIXES++))
                [ "$VERBOSE" = true ] && echo -e "${GREEN}FIXED${NC}"
                rm "$file.bak"
            else
                [ "$VERBOSE" = true ] && echo "NO CHANGE"
                rm "$file.bak"
            fi
        else
            ((MODIFIED++))
            ((TOTAL_FIXES++))
            [ "$VERBOSE" = true ] && echo "WOULD FIX"
        fi
    fi

done <<< "$ALL_FILES"

echo ""
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Files scanned:        $PROCESSED"
echo "Files modified:       $MODIFIED"
echo "main() fixes applied: $TOTAL_FIXES"
echo ""

if [ "$DRY_RUN" = false ] && [ $MODIFIED -gt 0 ]; then
    echo -e "${GREEN}Success! Fixed ${MODIFIED} main() functions.${NC}"
    echo ""
    echo "Pattern applied: main( → int\\nmain("
    echo ""
    echo "To verify changes:"
    echo "  git diff usr/src | grep -A2 '^+int$' | head -30"
    echo ""
elif [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}DRY RUN complete.${NC}"
    echo "Would fix ${TOTAL_FIXES} main() functions."
    echo ""
fi

exit 0
