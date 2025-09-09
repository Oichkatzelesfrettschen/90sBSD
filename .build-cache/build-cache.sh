#!/bin/bash
# Build Artifact Caching System

CACHE_VERSION="1.0"
CACHE_DIR="$BUILD_CACHE_DIR/objects"

cache_object() {
    local source="$1"
    local object="$2"
    local cache_key=$(echo "${source}-${CACHE_VERSION}" | md5sum | cut -d' ' -f1)
    local cache_path="$CACHE_DIR/$cache_key"
    
    if [[ -f "$object" ]]; then
        mkdir -p "$(dirname "$cache_path")"
        cp "$object" "$cache_path"
        echo "Cached: $object -> $cache_path"
    fi
}

restore_cached_object() {
    local source="$1"
    local object="$2"
    local cache_key=$(echo "${source}-${CACHE_VERSION}" | md5sum | cut -d' ' -f1)
    local cache_path="$CACHE_DIR/$cache_key"
    
    if [[ -f "$cache_path" ]]; then
        mkdir -p "$(dirname "$object")"
        cp "$cache_path" "$object"
        echo "Restored: $cache_path -> $object"
        return 0
    fi
    return 1
}

cleanup_cache() {
    local max_age_days=${1:-7}
    find "$CACHE_DIR" -type f -mtime +$max_age_days -delete
    echo "Cleaned cache files older than $max_age_days days"
}
