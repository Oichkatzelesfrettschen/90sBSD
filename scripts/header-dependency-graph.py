#!/usr/bin/env python3
"""Generate header dependency graph for analysis."""

import os
import re
import sys
from pathlib import Path
from collections import defaultdict
import json

def extract_includes(file_path):
    """Extract #include directives from a C/H file."""
    includes = []
    try:
        with open(file_path, 'r', errors='ignore') as f:
            for line in f:
                match = re.match(r'^\s*#\s*include\s*[<"]([^>"]+)[>"]', line)
                if match:
                    includes.append(match.group(1))
    except Exception as e:
        print(f"Warning: Could not read {file_path}: {e}", file=sys.stderr)
    return includes

def build_dependency_graph(src_dir):
    """Build complete dependency graph."""
    graph = defaultdict(list)
    file_count = 0

    for root, dirs, files in os.walk(src_dir):
        # Skip build artifacts
        if any(skip in root for skip in ['.git', 'obj', 'build', '__pycache__']):
            continue

        for file in files:
            if file.endswith(('.c', '.h')):
                file_path = Path(root) / file
                try:
                    rel_path = file_path.relative_to(src_dir)
                    includes = extract_includes(file_path)
                    graph[str(rel_path)] = includes
                    file_count += 1
                except ValueError:
                    # File is not relative to src_dir
                    pass

    return graph, file_count

def find_circular_dependencies(graph):
    """Detect circular include dependencies."""
    visited = set()
    rec_stack = set()
    cycles = []

    def dfs(node, path):
        if node not in graph:
            return

        visited.add(node)
        rec_stack.add(node)
        path = path + [node]

        for neighbor in graph[node]:
            # Normalize neighbor path
            neighbor_norm = neighbor.replace('../', '')

            if neighbor_norm not in visited:
                dfs(neighbor_norm, path)
            elif neighbor_norm in rec_stack:
                # Found a cycle
                try:
                    cycle_start = path.index(neighbor_norm)
                    cycle = path[cycle_start:] + [neighbor_norm]
                    if cycle not in cycles:
                        cycles.append(cycle)
                except ValueError:
                    pass

        rec_stack.discard(node)

    for node in list(graph.keys()):
        if node not in visited:
            dfs(node, [])

    return cycles

def analyze_include_depth(graph):
    """Calculate include depth for each file."""
    depths = {}

    def calc_depth(node, visited=None):
        if visited is None:
            visited = set()

        if node in visited:
            return 0  # Circular dependency
        if node not in graph:
            return 0

        visited.add(node)
        max_depth = 0

        for include in graph[node]:
            include_norm = include.replace('../', '')
            depth = calc_depth(include_norm, visited.copy())
            max_depth = max(max_depth, depth + 1)

        return max_depth

    for node in graph:
        depths[node] = calc_depth(node)

    return depths

def main():
    src_dir = sys.argv[1] if len(sys.argv) > 1 else '/home/user/386bsd/usr/src'

    print(f"📊 Analyzing header dependencies in {src_dir}...")
    graph, file_count = build_dependency_graph(src_dir)

    print(f"   Found {file_count} C/H files")
    print(f"   Analyzed {len(graph)} files with includes")

    # Find cycles
    print("\n🔍 Detecting circular dependencies...")
    cycles = find_circular_dependencies(graph)
    if cycles:
        print(f"   ⚠️  Found {len(cycles)} circular dependencies:")
        for i, cycle in enumerate(cycles[:10], 1):  # Show first 10
            print(f"      {i}. {' -> '.join(cycle)}")
        if len(cycles) > 10:
            print(f"      ... and {len(cycles) - 10} more")
    else:
        print("   ✅ No circular dependencies found")

    # Analyze depths
    print("\n📏 Calculating include depths...")
    depths = analyze_include_depth(graph)
    max_depth = max(depths.values()) if depths else 0
    avg_depth = sum(depths.values()) / len(depths) if depths else 0

    print(f"   Maximum include depth: {max_depth}")
    print(f"   Average include depth: {avg_depth:.2f}")

    # Find deepest includes
    deepest = sorted(depths.items(), key=lambda x: x[1], reverse=True)[:10]
    print("\n   Deepest include chains:")
    for file, depth in deepest:
        print(f"      {depth:3d} - {file}")

    # Save graph for visualization
    output_dir = Path('/home/user/386bsd/logs/analysis')
    output_dir.mkdir(parents=True, exist_ok=True)

    output_path = output_dir / 'header-deps.json'
    with open(output_path, 'w') as f:
        json.dump({
            'graph': graph,
            'depths': depths,
            'cycles': [[str(n) for n in cycle] for cycle in cycles],
            'stats': {
                'file_count': file_count,
                'max_depth': max_depth,
                'avg_depth': avg_depth,
                'cycle_count': len(cycles)
            }
        }, f, indent=2)

    print(f"\n💾 Full analysis saved to {output_path}")

    # Generate summary
    summary_path = output_dir / 'header-deps-summary.txt'
    with open(summary_path, 'w') as f:
        f.write("Header Dependency Analysis Summary\n")
        f.write("=" * 40 + "\n\n")
        f.write(f"Total files analyzed: {file_count}\n")
        f.write(f"Files with includes: {len(graph)}\n")
        f.write(f"Maximum include depth: {max_depth}\n")
        f.write(f"Average include depth: {avg_depth:.2f}\n")
        f.write(f"Circular dependencies: {len(cycles)}\n")

    print(f"📄 Summary saved to {summary_path}")
    print("\n✅ Analysis complete!")

    return 0 if len(cycles) == 0 else 1

if __name__ == '__main__':
    sys.exit(main())
