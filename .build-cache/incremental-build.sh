#!/bin/bash
# Incremental Build Support for 386BSD

track_file_changes() {
    local file="$1"
    local checksum=$(md5sum "$file" 2>/dev/null | cut -d' ' -f1)
    local cache_file="$BUILD_CACHE_DIR/checksums/$(echo "$file" | tr '/' '_').md5"
    
    mkdir -p "$BUILD_CACHE_DIR/checksums"
    
    if [[ -f "$cache_file" ]]; then
        local old_checksum=$(cat "$cache_file")
        if [[ "$checksum" != "$old_checksum" ]]; then
            echo "changed"
            echo "$checksum" > "$cache_file"
        else
            echo "unchanged"
        fi
    else
        echo "new"
        echo "$checksum" > "$cache_file"
    fi
}

needs_rebuild() {
    local source="$1"
    local target="$2"
    
    # Check if target exists
    [[ ! -f "$target" ]] && return 0
    
    # Check if source is newer
    [[ "$source" -nt "$target" ]] && return 0
    
    # Check dependencies
    local status=$(track_file_changes "$source")
    [[ "$status" != "unchanged" ]] && return 0
    
    return 1
}
