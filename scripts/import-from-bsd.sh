#!/bin/bash
#
# BSD Component Import Script
# Imports source files from various BSD distributions into 386BSD
#
# Usage: ./import-from-bsd.sh <source_repo> <source_path> <dest_path> [options]
#
# Example:
#   ./import-from-bsd.sh ../bsd-sources/4.4BSD-Lite2 \
#       usr/src/sys/i386/boot \
#       usr/src/bootstrap
#

set -e  # Exit on error
set -u  # Exit on undefined variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Import log
IMPORT_LOG="$REPO_ROOT/IMPORT_LOG.txt"

# Function: Print usage
usage() {
    cat <<EOF
BSD Component Import Script

Usage: $0 <source_repo> <source_path> <dest_path> [options]

Arguments:
  source_repo   Path to BSD source repository (e.g., ../bsd-sources/4.4BSD-Lite2)
  source_path   Relative path within source repo (e.g., usr/src/sys/i386)
  dest_path     Destination path in 386bsd repo (e.g., usr/src/kernel/i386)

Options:
  --dry-run     Show what would be imported without actually copying
  --force       Overwrite existing files
  --no-header   Don't add import header comments
  --preserve    Preserve timestamps and permissions
  --verbose     Verbose output

Examples:
  # Import bootloader from 4.4BSD-Lite2
  $0 ../bsd-sources/4.4BSD-Lite2 usr/src/sys/i386/boot usr/src/bootstrap

  # Import virtio drivers from NetBSD (dry run)
  $0 --dry-run ../bsd-sources/netbsd sys/dev/virtio usr/src/kernel/virtio

  # Import missing headers with force overwrite
  $0 --force ../bsd-sources/4.4BSD-Lite2 usr/include/sys usr/src/include/sys
EOF
    exit 1
}

# Function: Print colored message
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

# Parse arguments
DRY_RUN=0
FORCE=0
NO_HEADER=0
PRESERVE=0
VERBOSE=0

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --no-header)
            NO_HEADER=1
            shift
            ;;
        --preserve)
            PRESERVE=1
            shift
            ;;
        --verbose)
            VERBOSE=1
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            log_error "Unknown option: $1"
            usage
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Restore positional arguments
set -- "${POSITIONAL_ARGS[@]}"

# Validate arguments
if [ $# -lt 3 ]; then
    log_error "Missing required arguments"
    usage
fi

SOURCE_REPO="$1"
SOURCE_PATH="$2"
DEST_PATH="$3"

# Resolve paths
SOURCE_FULL="$SOURCE_REPO/$SOURCE_PATH"
DEST_FULL="$REPO_ROOT/$DEST_PATH"

# Validate source exists
if [ ! -e "$SOURCE_FULL" ]; then
    log_error "Source path does not exist: $SOURCE_FULL"
    exit 1
fi

# Get source repository name
SOURCE_REPO_NAME=$(basename "$SOURCE_REPO")

# Display import plan
echo ""
log_info "=== BSD Component Import Plan ==="
echo "  Source Repository: $SOURCE_REPO_NAME"
echo "  Source Path:       $SOURCE_PATH"
echo "  Destination:       $DEST_PATH"
echo "  Full Source:       $SOURCE_FULL"
echo "  Full Destination:  $DEST_FULL"
echo ""

if [ $DRY_RUN -eq 1 ]; then
    log_warning "DRY RUN MODE - No files will be modified"
fi

# Count files to import
if [ -d "$SOURCE_FULL" ]; then
    FILE_COUNT=$(find "$SOURCE_FULL" -type f | wc -l)
    log_info "Files to import: $FILE_COUNT"
elif [ -f "$SOURCE_FULL" ]; then
    FILE_COUNT=1
    log_info "Importing single file"
fi

# Check if destination exists
if [ -e "$DEST_FULL" ] && [ $FORCE -eq 0 ]; then
    log_warning "Destination already exists: $DEST_FULL"
    read -p "Overwrite? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Import cancelled"
        exit 0
    fi
fi

# Create destination directory
if [ $DRY_RUN -eq 0 ]; then
    mkdir -p "$(dirname "$DEST_FULL")"
fi

# Import files
log_info "Importing files..."

RSYNC_OPTS="-av"
[ $VERBOSE -eq 1 ] && RSYNC_OPTS="${RSYNC_OPTS} --progress"
[ $PRESERVE -eq 1 ] && RSYNC_OPTS="${RSYNC_OPTS} --times --perms"
[ $DRY_RUN -eq 1 ] && RSYNC_OPTS="${RSYNC_OPTS} --dry-run"

if command -v rsync &> /dev/null; then
    rsync $RSYNC_OPTS "$SOURCE_FULL" "$(dirname "$DEST_FULL")/"
else
    # Fallback to cp
    log_warning "rsync not found, using cp (less efficient)"
    if [ $DRY_RUN -eq 0 ]; then
        if [ -d "$SOURCE_FULL" ]; then
            cp -r "$SOURCE_FULL" "$DEST_FULL"
        else
            cp "$SOURCE_FULL" "$DEST_FULL"
        fi
    fi
fi

# Add import headers to C/H files
if [ $NO_HEADER -eq 0 ] && [ $DRY_RUN -eq 0 ]; then
    log_info "Adding import headers to source files..."

    find "$DEST_FULL" -type f \( -name "*.c" -o -name "*.h" -o -name "*.S" \) 2>/dev/null | while read -r file; do
        # Check if file already has import header
        if ! grep -q "Imported from" "$file" 2>/dev/null; then
            # Get file extension
            ext="${file##*.}"

            # Create temp file with header
            TEMP_FILE=$(mktemp)

            case "$ext" in
                c|h|S)
                    cat > "$TEMP_FILE" <<EOF
/*
 * Imported from $SOURCE_REPO_NAME
 * Source: $SOURCE_PATH
 * Date: $(date +%Y-%m-%d)
 *
 * This file has been imported from the $SOURCE_REPO_NAME BSD distribution
 * and may have been modified for compatibility with 386BSD.
 */

EOF
                    cat "$file" >> "$TEMP_FILE"
                    mv "$TEMP_FILE" "$file"
                    ;;
            esac

            [ $VERBOSE -eq 1 ] && echo "  Added header: $(basename "$file")"
        fi
    done
fi

# Update import log
if [ $DRY_RUN -eq 0 ]; then
    {
        echo "=== Import: $(date) ==="
        echo "Source: $SOURCE_REPO_NAME/$SOURCE_PATH"
        echo "Destination: $DEST_PATH"
        echo "Files: $FILE_COUNT"
        echo ""
    } >> "$IMPORT_LOG"

    log_success "Import logged to: $IMPORT_LOG"
fi

# Display summary
echo ""
log_success "=== Import Complete ==="
echo "  Imported from: $SOURCE_REPO_NAME"
echo "  Files copied:  $FILE_COUNT"
echo "  Destination:   $DEST_PATH"
echo ""

if [ $DRY_RUN -eq 0 ]; then
    log_info "Next steps:"
    echo "  1. Review imported files in: $DEST_FULL"
    echo "  2. Update Makefiles to include new files"
    echo "  3. Fix any compilation errors"
    echo "  4. Test build: cd $DEST_FULL && make"
    echo "  5. Commit changes: git add $DEST_PATH && git commit"
else
    log_info "This was a dry run. Use without --dry-run to perform actual import."
fi

echo ""
