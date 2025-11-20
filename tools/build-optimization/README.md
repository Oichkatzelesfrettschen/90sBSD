# Build Optimization Tools

This directory contains infrastructure for optimizing the BSD kernel build process.

## Components

### cache/
Build caching and dependency tracking system.

**Files:**
- `build-cache.sh` - Main build caching logic
- `build.conf` - Build optimization configuration
- `incremental-build.sh` - Incremental build support
- `parallel-build.sh` - Parallel compilation support
- `dependencies/dependency-graph.json` - Dependency tracking data

**Features:**
- Parallel builds (configurable job count)
- Incremental compilation
- Dependency tracking
- Build artifact caching

### metrics/
Build performance metrics collection.

**Files:**
- `collect-metrics.sh` - Metrics collection system

**Tracks:**
- Build duration
- System resource usage
- Build success/failure rates
- Historical build performance

## Usage

These tools are integrated into `scripts/build-orchestrator.sh`. They are automatically used when running orchestrated builds.

### Configuration

Edit `cache/build.conf` to customize:
```bash
ENABLE_PARALLEL_BUILD=true
ENABLE_INCREMENTAL_BUILD=true
ENABLE_BUILD_CACHING=true
ENABLE_DEPENDENCY_TRACKING=true
ENABLE_BUILD_METRICS=true
MAX_PARALLEL_JOBS=4
BUILD_OPTIMIZATION_LEVEL=2
```

### Manual Usage

```bash
# Enable build caching
source tools/build-optimization/cache/build-cache.sh

# Enable metrics collection
source tools/build-optimization/metrics/collect-metrics.sh
start_build_timer
# ... build commands ...
end_build_timer
```

## Integration

Referenced by:
- `scripts/build-orchestrator.sh` - Main build orchestration script

## Notes

- These tools are designed to work with the BSD kernel build system
- Runtime data (logs, JSON metrics) are excluded by `.gitignore`
- Infrastructure files (scripts, config) are tracked in version control
