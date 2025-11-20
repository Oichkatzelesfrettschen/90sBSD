#!/bin/bash
# Build Metrics Collection System

METRICS_FILE="$BUILD_METRICS_DIR/build-metrics.json"

start_build_timer() {
    echo $(date +%s) > "$BUILD_METRICS_DIR/build-start.tmp"
}

end_build_timer() {
    local start_time=$(cat "$BUILD_METRICS_DIR/build-start.tmp" 2>/dev/null || echo 0)
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Update metrics
    cat > "$METRICS_FILE" << EOF
{
  "last_build": {
    "timestamp": "$(date -Iseconds)",
    "duration_seconds": $duration,
    "start_time": $start_time,
    "end_time": $end_time
  },
  "system_info": {
    "cpu_cores": $(nproc),
    "memory_gb": $(free -g | awk '/^Mem:/{print $2}'),
    "disk_free_gb": $(df . | awk 'NR==2{print int($4/1024/1024)}')"
  }
}
