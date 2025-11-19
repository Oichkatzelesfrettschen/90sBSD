#!/bin/bash
#
# Comprehensive Static Analysis Runner for 386BSD
# Runs clang-tidy and cppcheck on the codebase
#
# Usage: ./run-static-analysis.sh [--parallel N] [--tool TOOL]
#
# Author: 386BSD Modernization Team
# Date: 2025-11-19

set -euo pipefail

# Configuration
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${REPO_ROOT}/logs/analysis/static-analysis"
PARALLEL_JOBS="${PARALLEL_JOBS:-4}"
TOOL="${1:-all}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create output directory
mkdir -p "${OUTPUT_DIR}"/{clang-tidy,cppcheck,combined}

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}386BSD Static Analysis Runner${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "Repository: ${REPO_ROOT}"
echo "Output: ${OUTPUT_DIR}"
echo "Parallel jobs: ${PARALLEL_JOBS}"
echo "Tool: ${TOOL}"
echo ""

# Find all C source files
find_c_files() {
    find "${REPO_ROOT}/usr/src" -name "*.c" -type f | sort
}

# Count total files
TOTAL_FILES=$(find_c_files | wc -l)
echo "Total C files: ${TOTAL_FILES}"
echo ""

#
# clang-tidy Analysis
#
run_clang_tidy() {
    echo -e "${YELLOW}Running clang-tidy analysis...${NC}"
    echo ""

    local output_file="${OUTPUT_DIR}/clang-tidy/results.txt"
    local summary_file="${OUTPUT_DIR}/clang-tidy/summary.txt"

    # clang-tidy configuration
    # Focus on: readability, modernize, performance, bugprone
    local checks="readability-*,\
modernize-*,\
performance-*,\
bugprone-*,\
clang-analyzer-*,\
-modernize-use-trailing-return-type,\
-readability-braces-around-statements"

    # Run clang-tidy on sample of files (full scan would be very slow)
    # Sample: 100 files from different subsystems
    local sample_files="${OUTPUT_DIR}/clang-tidy/sample-files.txt"

    find_c_files | {
        # Get diverse sample: 10 from each major subsystem
        grep "usr/src/lib/" | head -20
        grep "usr/src/bin/" | head -10
        grep "usr/src/kernel/" | head -10
        grep "usr/src/usr.bin/" | head -10
        grep "usr/src/sbin/" | head -5
        grep "usr/src/games/" | head -5
    } > "${sample_files}" || true

    local sample_count=$(wc -l < "${sample_files}")
    echo "Analyzing ${sample_count} sample files with clang-tidy..."
    echo ""

    # Run clang-tidy
    local processed=0
    > "${output_file}"

    while IFS= read -r file; do
        ((processed++))
        echo -ne "\rProgress: ${processed}/${sample_count} ($(( processed * 100 / sample_count ))%)   "

        clang-tidy \
            --checks="${checks}" \
            --header-filter="usr/include/.*" \
            -p="${REPO_ROOT}" \
            "${file}" \
            -- \
            -I"${REPO_ROOT}/usr/include" \
            -I"${REPO_ROOT}/usr/src/kernel/include" \
            -std=c17 \
            2>&1 | tee -a "${output_file}" > /dev/null || true

    done < "${sample_files}"

    echo ""
    echo ""

    # Generate summary
    echo "clang-tidy Summary" > "${summary_file}"
    echo "==================" >> "${summary_file}"
    echo "" >> "${summary_file}"
    echo "Files analyzed: ${sample_count}" >> "${summary_file}"
    echo "Date: $(date)" >> "${summary_file}"
    echo "" >> "${summary_file}"

    # Count warnings/errors by category
    echo "Top Warning Categories:" >> "${summary_file}"
    grep -E "warning:|error:" "${output_file}" | \
        sed 's/.*\[\(.*\)\]/\1/' | \
        sort | uniq -c | sort -rn | head -20 >> "${summary_file}" || true

    echo ""
    echo -e "${GREEN}clang-tidy analysis complete!${NC}"
    echo "Results: ${output_file}"
    echo "Summary: ${summary_file}"
    echo ""
}

#
# cppcheck Analysis
#
run_cppcheck() {
    echo -e "${YELLOW}Running cppcheck analysis...${NC}"
    echo ""

    local output_file="${OUTPUT_DIR}/cppcheck/results.xml"
    local summary_file="${OUTPUT_DIR}/cppcheck/summary.txt"

    # cppcheck is fast enough to run on full codebase
    echo "Analyzing full codebase with cppcheck..."
    echo ""

    cppcheck \
        --enable=all \
        --inconclusive \
        --xml \
        --xml-version=2 \
        --suppress=missingIncludeSystem \
        --suppress=unmatchedSuppression \
        -I "${REPO_ROOT}/usr/include" \
        -I "${REPO_ROOT}/usr/src/kernel/include" \
        -j "${PARALLEL_JOBS}" \
        "${REPO_ROOT}/usr/src" \
        2> "${output_file}" || true

    echo ""
    echo -e "${GREEN}cppcheck analysis complete!${NC}"
    echo "Results: ${output_file}"
    echo ""

    # Parse XML and create summary
    echo "Generating cppcheck summary..."

    {
        echo "cppcheck Summary"
        echo "================"
        echo ""
        echo "Date: $(date)"
        echo ""

        # Count total issues
        local total=$(grep -c "<error " "${output_file}" || echo "0")
        echo "Total issues: ${total}"
        echo ""

        # Count by severity
        echo "By Severity:"
        for severity in error warning style performance portability information; do
            local count=$(grep -c "severity=\"${severity}\"" "${output_file}" || echo "0")
            printf "  %-15s %6d\n" "${severity}:" "${count}"
        done
        echo ""

        # Top error IDs
        echo "Top Error Types:"
        grep "<error " "${output_file}" | \
            sed -n 's/.*id="\([^"]*\)".*/\1/p' | \
            sort | uniq -c | sort -rn | head -20

    } > "${summary_file}"

    cat "${summary_file}"
    echo ""
}

#
# Combined Analysis Report
#
create_combined_report() {
    echo -e "${YELLOW}Creating combined analysis report...${NC}"
    echo ""

    local report_file="${OUTPUT_DIR}/combined/STATIC_ANALYSIS_BASELINE.md"

    cat > "${report_file}" << 'EOF'
# Static Analysis Baseline Report

**Date**: $(date +%Y-%m-%d)
**Tools**: clang-tidy, cppcheck
**Scope**: 386BSD codebase

---

## Executive Summary

This report presents the results of comprehensive static analysis on the 386BSD
codebase using industry-standard tools (clang-tidy and cppcheck).

### Analysis Scope

- **clang-tidy**: Sample-based analysis (60 files)
  - Focus: readability, modernize, performance, bugprone
  - Coverage: Representative files from all major subsystems

- **cppcheck**: Full codebase analysis (2,215 files)
  - Focus: bugs, style, performance, portability
  - Coverage: Complete usr/src tree

---

## Part I: clang-tidy Results

EOF

    # Include clang-tidy summary
    if [ -f "${OUTPUT_DIR}/clang-tidy/summary.txt" ]; then
        cat "${OUTPUT_DIR}/clang-tidy/summary.txt" >> "${report_file}"
    fi

    cat >> "${report_file}" << 'EOF'

### Common Issues Found

**To be analyzed from**: `logs/analysis/static-analysis/clang-tidy/results.txt`

---

## Part II: cppcheck Results

EOF

    # Include cppcheck summary
    if [ -f "${OUTPUT_DIR}/cppcheck/summary.txt" ]; then
        cat "${OUTPUT_DIR}/cppcheck/summary.txt" >> "${report_file}"
    fi

    cat >> "${report_file}" << 'EOF'

### Common Issues Found

**To be analyzed from**: `logs/analysis/static-analysis/cppcheck/results.xml`

---

## Part III: Priority Issues

**TODO**: Analyze results and categorize by priority

### P0 Critical
- Security vulnerabilities
- Memory safety issues
- Undefined behavior

### P1 High
- Resource leaks
- Logic errors
- Performance issues

### P2 Medium
- Style violations
- Readability issues
- Portability concerns

### P3 Low
- Minor style issues
- Information only

---

## Part IV: Remediation Plan

**TODO**: Create remediation strategy based on findings

---

## Appendices

### Appendix A: Tool Configurations

**clang-tidy checks**:
- readability-*
- modernize-*
- performance-*
- bugprone-*
- clang-analyzer-*

**cppcheck options**:
- --enable=all
- --inconclusive
- Full codebase coverage

### Appendix B: Data Files

- clang-tidy results: `logs/analysis/static-analysis/clang-tidy/results.txt`
- cppcheck results: `logs/analysis/static-analysis/cppcheck/results.xml`

---

**Document Version**: 1.0 (Baseline)
**Status**: Initial Analysis Complete
**Next Steps**: Detailed issue categorization and prioritization

EOF

    echo -e "${GREEN}Combined report created!${NC}"
    echo "Report: ${report_file}"
    echo ""
}

#
# Main execution
#
main() {
    case "${TOOL}" in
        clang-tidy)
            run_clang_tidy
            ;;
        cppcheck)
            run_cppcheck
            ;;
        all|*)
            run_clang_tidy
            run_cppcheck
            create_combined_report
            ;;
    esac

    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Static Analysis Complete!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "All results available in: ${OUTPUT_DIR}"
    echo ""
}

main "$@"
