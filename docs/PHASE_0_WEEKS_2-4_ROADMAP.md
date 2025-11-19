# Phase 0, Weeks 2-4: Detailed Execution Roadmap
**Planning Date**: 2025-11-19
**Status**: Ready for Execution
**Prerequisite**: Week 1 Complete ✅

---

## Executive Summary

With Week 1's critical header guard addition complete (ahead of schedule), we now proceed to **baseline establishment**, **analysis**, and **Phase 1 preparation**. This roadmap provides granular, day-by-day tasks for Weeks 2-4.

**Key Objectives**:
1. Establish complete C17 compliance baseline
2. Run comprehensive static analysis
3. Consolidate all findings
4. Create detailed Phase 1 execution plan

---

## Week 2: Baseline Establishment (Days 6-10)

### Day 6: C17 Baseline Build Attempt (Part 1)

**Duration**: 6-8 hours
**Priority**: P1 (High)
**Goal**: Document current C17 compliance state

#### Morning Tasks (4 hours)

**Task 1: Prepare Build Environment** (1 hour)
```bash
# 1. Verify toolchain
clang --version  # Should be 15+
which bmake || which make

# 2. Clean build tree
cd /home/user/386bsd/usr/src
bmake clean 2>/dev/null || make clean 2>/dev/null || true

# 3. Create log directory
mkdir -p ../logs/build/c17-baseline
```

**Task 2: Initial C17 Compilation Attempt** (3 hours)
```bash
# Attempt with minimal C17 flags first
cd /home/user/386bsd/usr/src

# Attempt 1: Just C17 standard (no pedantic yet)
make CC=clang CFLAGS="-std=c17" 2>&1 | \
  tee ../logs/build/c17-baseline/attempt1-c17only.log || true

# Count errors and warnings
echo "Attempt 1 Statistics:" | tee ../logs/build/c17-baseline/stats.txt
grep -c "error:" ../logs/build/c17-baseline/attempt1-c17only.log || echo 0
grep -c "warning:" ../logs/build/c17-baseline/attempt1-c17only.log || echo 0
```

#### Afternoon Tasks (4 hours)

**Task 3: C17 + Pedantic Attempt** (2 hours)
```bash
# Attempt 2: C17 with pedantic warnings
make clean
make CC=clang CFLAGS="-std=c17 -pedantic" 2>&1 | \
  tee ../logs/build/c17-baseline/attempt2-pedantic.log || true

# Extract error categories
grep "error:" ../logs/build/c17-baseline/attempt2-pedantic.log | \
  cut -d: -f4 | sort | uniq -c | sort -rn > \
  ../logs/build/c17-baseline/error-categories.txt
```

**Task 4: Analyze Error Patterns** (2 hours)
```bash
# Create categorized analysis
cat > ../logs/analysis/c17-errors-analysis.txt <<'EOF'
C17 Compilation Error Analysis
================================

Top Error Categories:
EOF

head -20 ../logs/build/c17-baseline/error-categories.txt >> \
  ../logs/analysis/c17-errors-analysis.txt

# Identify most common subsystems with errors
grep "error:" ../logs/build/c17-baseline/attempt2-pedantic.log | \
  cut -d: -f1 | xargs dirname | sort | uniq -c | sort -rn | head -20 >> \
  ../logs/analysis/c17-errors-by-subsystem.txt
```

**Deliverables**:
- [ ] C17 build attempt logs (2 attempts)
- [ ] Error categorization by type
- [ ] Error categorization by subsystem
- [ ] Initial statistics

---

### Day 7: C17 Analysis Deep Dive

**Duration**: 6-8 hours
**Priority**: P1 (High)
**Goal**: Categorize and prioritize all C17 issues

#### Morning Tasks (4 hours)

**Task 1: Create Detailed Error Database** (3 hours)

Create `scripts/analyze-c17-errors.py`:
```python
#!/usr/bin/env python3
"""Analyze C17 compilation errors and create issue database."""

import re
import sys
from collections import defaultdict
from pathlib import Path

def parse_log(log_file):
    """Parse compilation log and extract errors."""
    errors = []

    with open(log_file, 'r') as f:
        for line in f:
            # Match: file.c:line:col: error: message
            match = re.match(r'([^:]+):(\d+):(\d+):\s*error:\s*(.+)', line)
            if match:
                errors.append({
                    'file': match.group(1),
                    'line': int(match.group(2)),
                    'col': int(match.group(3)),
                    'message': match.group(4).strip()
                })

    return errors

def categorize_errors(errors):
    """Categorize errors by type."""
    categories = defaultdict(list)

    for error in errors:
        msg = error['message']

        # Categorize based on error message patterns
        if 'implicit' in msg.lower():
            categories['Implicit declarations'].append(error)
        elif 'incompatible' in msg.lower():
            categories['Type incompatibility'].append(error)
        elif 'undeclared' in msg.lower():
            categories['Undeclared identifiers'].append(error)
        elif 'conflicting' in msg.lower():
            categories['Conflicting types'].append(error)
        elif 'expected' in msg.lower():
            categories['Syntax errors'].append(error)
        elif 'unknown type' in msg.lower():
            categories['Unknown types'].append(error)
        else:
            categories['Other'].append(error)

    return categories

def main():
    log_file = sys.argv[1] if len(sys.argv) > 1 else \
               'logs/build/c17-baseline/attempt2-pedantic.log'

    print(f"Analyzing {log_file}...")
    errors = parse_log(log_file)
    categories = categorize_errors(errors)

    print(f"\nTotal errors: {len(errors)}")
    print("\nBy category:")
    for category, err_list in sorted(categories.items(),
                                     key=lambda x: len(x[1]),
                                     reverse=True):
        print(f"  {category}: {len(err_list)}")

    # Generate CSV for tracking
    output_csv = Path('logs/analysis/c17-errors.csv')
    output_csv.parent.mkdir(parents=True, exist_ok=True)

    with open(output_csv, 'w') as f:
        f.write("File,Line,Category,Message,Priority,Status\n")
        for category, err_list in categories.items():
            for err in err_list[:100]:  # Limit for manageability
                priority = 'P1' if category in ['Implicit declarations',
                                                 'Undeclared identifiers'] else 'P2'
                f.write(f'"{err["file"]}",{err["line"]},"{category}",'
                       f'"{err["message"]}",{priority},Open\n')

    print(f"\nCSV saved to {output_csv}")

if __name__ == '__main__':
    main()
```

**Task 2: Run Analysis** (1 hour)
```bash
chmod +x scripts/analyze-c17-errors.py
python3 scripts/analyze-c17-errors.py
```

#### Afternoon Tasks (4 hours)

**Task 3: Create Issue Tracker** (2 hours)

Create comprehensive issue tracking spreadsheet:
```bash
cat > logs/analysis/c17-issues-tracker.md <<'EOF'
# C17 Compliance Issue Tracker

## Summary Statistics
- Total errors: TBD
- By priority:
  - P0 (Critical): TBD
  - P1 (High): TBD
  - P2 (Medium): TBD
  - P3 (Low): TBD

## Issues by Category

### P0: Critical Blockers
| ID | Category | Count | Subsystem | Strategy |
|----|----------|-------|-----------|----------|
| C17-001 | Implicit declarations | TBD | kernel | Add prototypes |
| C17-002 | Undeclared identifiers | TBD | libc | Add includes |

### P1: High Priority
| ID | Category | Count | Subsystem | Strategy |
|----|----------|-------|-----------|----------|

### P2: Medium Priority
| ID | Category | Count | Subsystem | Strategy |
|----|----------|-------|-----------|----------|
EOF
```

**Task 4: Document Baseline State** (2 hours)

Create `docs/build/C17_BASELINE_REPORT.md`:
```markdown
# C17 Baseline Compliance Report

**Date**: 2025-11-19
**Compiler**: Clang 15+
**Standard**: C17 (ISO/IEC 9899:2018)

## Executive Summary

First attempt to compile 386BSD with strict C17 compliance revealed
[TBD] errors and [TBD] warnings across [TBD] source files.

## Detailed Findings

### Error Distribution
[Include charts/tables from analysis]

### Top Issues
1. **Category**: Count, affected files
2. **Category**: Count, affected files

### Subsystem Breakdown
- kernel/: X errors
- lib/: Y errors
- bin/: Z errors

## Remediation Strategy
[Based on analysis, propose fix strategy]

## Next Steps
1. Prioritize P0/P1 issues
2. Create automated fix scripts where possible
3. Begin systematic remediation in Phase 1
```

**Deliverables**:
- [ ] C17 error analysis script
- [ ] Categorized error database (CSV)
- [ ] Issue tracker document
- [ ] C17 baseline report

---

### Day 8: Comprehensive Static Analysis

**Duration**: 6-8 hours
**Priority**: P1 (High)
**Goal**: Complete static analysis baseline

#### Full Day Execution

**Task 1: Run Static Analysis Suite** (2 hours automated, 1 hour setup)
```bash
cd /home/user/386bsd

# Run comprehensive static analysis
./scripts/static-analysis.sh 2>&1 | \
  tee logs/analysis/static-analysis-full-$(date +%Y%m%d).log

# This will take time - runs in background, monitor with:
tail -f logs/analysis/static-analysis-full-*.log
```

**Task 2: While Running - Create Analysis Tools** (3 hours)

Create `scripts/prioritize-static-issues.py`:
```python
#!/usr/bin/env python3
"""Prioritize static analysis findings."""

import re
from pathlib import Path
from collections import defaultdict

# Priority weights for issue types
PRIORITY_WEIGHTS = {
    'buffer-overflow': 10,
    'use-after-free': 10,
    'null-dereference': 9,
    'uninitialized': 8,
    'memory-leak': 7,
    'data-race': 9,
    'deadlock': 9,
    'integer-overflow': 7,
    'division-by-zero': 8,
    'format-string': 9,
    'deprecated': 3,
    'style': 1,
}

def prioritize_findings(findings_file):
    """Read and prioritize static analysis findings."""
    findings = []

    with open(findings_file, 'r') as f:
        for line in f:
            # Parse clang-tidy/cppcheck output
            # Format: file:line: warning: message [check-name]
            match = re.match(r'([^:]+):(\d+):\s*warning:\s*(.+?)\s*\[([^\]]+)\]',
                           line)
            if match:
                finding = {
                    'file': match.group(1),
                    'line': int(match.group(2)),
                    'message': match.group(3),
                    'check': match.group(4),
                    'priority': calculate_priority(match.group(4), match.group(3))
                }
                findings.append(finding)

    return sorted(findings, key=lambda x: x['priority'], reverse=True)

def calculate_priority(check_name, message):
    """Calculate priority based on check type and message."""
    check_lower = check_name.lower()
    msg_lower = message.lower()

    for key, weight in PRIORITY_WEIGHTS.items():
        if key in check_lower or key in msg_lower:
            return weight

    return 5  # Default medium priority

def main():
    findings_file = Path('logs/analysis/static-analysis-full-*.log')
    # ... implementation
    pass

if __name__ == '__main__':
    main()
```

**Task 3: Analyze Results** (2 hours)
```bash
# After static analysis completes, analyze results
python3 scripts/prioritize-static-issues.py

# Generate summary reports
cat logs/analysis/analysis-master-summary-*.txt
cat logs/analysis/todos-summary-*.txt
cat logs/analysis/kr-functions-*.txt
```

**Deliverables**:
- [ ] Complete static analysis logs
- [ ] Prioritized findings database
- [ ] Security issue list (high priority)
- [ ] Code quality metrics

---

### Day 9: Consolidation - Master Baseline Report

**Duration**: 8 hours
**Priority**: P1 (High)
**Goal**: Synthesize all baseline data

#### Task: Create Comprehensive Master Baseline

Create `docs/standards/MASTER_BASELINE_REPORT.md`:

**Structure**:
```markdown
# 386BSD Master Baseline Report - Phase 0 Complete

## Executive Summary
[High-level overview of current state]

## Part I: Code Metrics
- LOC, files, functions
- From: logs/metrics/baseline-summary-*.txt

## Part II: C17 Compliance
- Error counts by category
- Subsystem breakdown
- Prioritized remediation plan
- From: C17_BASELINE_REPORT.md

## Part III: Static Analysis
- Security issues
- Code quality issues
- Technical debt markers
- From: static-analysis logs

## Part IV: Header Analysis
- Dependency graph
- Circular dependencies (0!)
- Include depth metrics
- From: header-deps.json

## Part V: Build System
- Makefile inventory
- Toolchain status
- Build time baseline
- From: build-system analysis

## Part VI: Integrated Assessment
- Strengths (what's good)
- Weaknesses (what needs work)
- Opportunities (quick wins)
- Threats (major risks)

## Part VII: Phase 1 Readiness
- Prerequisites met
- Blockers identified
- Resources allocated
- Timeline confirmed
```

**Time Breakdown**:
- 2 hours: Data collection and organization
- 3 hours: Writing and synthesis
- 2 hours: Charts/visualizations (if possible)
- 1 hour: Review and refinement

**Deliverables**:
- [ ] Master baseline report (comprehensive)
- [ ] Executive summary (2 pages)
- [ ] Presentation-ready findings

---

### Day 10: Tool Refinement & Automation

**Duration**: 6-8 hours
**Priority**: P2 (Medium)
**Goal**: Improve tools based on findings

#### Morning Tasks (4 hours)

**Task 1: Enhance Analysis Scripts** (2 hours)

Based on Week 2 findings, improve:

1. **static-analysis.sh** enhancements:
   - Add progress indicators
   - Improve error categorization
   - Add differential analysis (compare runs)
   - Add HTML report generation

2. **collect-baseline-metrics.sh** enhancements:
   - Add trend tracking
   - Add comparison with previous runs
   - Add visualization output

**Task 2: Create Migration Helper Scripts** (2 hours)

Create `scripts/fix-common-c17-issues.sh`:
```bash
#!/usr/bin/env bash
# Automated fixes for common C17 issues

set -euo pipefail

echo "🔧 Automated C17 Issue Fixer"
echo "============================"

# Fix 1: Add missing #include <stdint.h> where needed
echo "[1/5] Adding missing stdint.h includes..."
for file in $(grep -l "u_int32_t\|u_int16_t\|u_int8_t" usr/src/**/*.c 2>/dev/null); do
  if ! grep -q "#include <stdint.h>" "$file"; then
    # Add after last system include
    sed -i '/#include <sys\/types.h>/a #include <stdint.h>' "$file"
    echo "  Fixed: $file"
  fi
done

# Fix 2: Convert old-style function definitions (simple cases)
echo "[2/5] Converting simple K&R function definitions..."
# (This is complex - start with detection only)
find usr/src -name "*.c" -type f | \
  xargs grep -l "^[a-zA-Z_][a-zA-Z0-9_]*([^)]*)\$" > \
  logs/analysis/kr-candidates-for-conversion.txt

echo "  Found $(wc -l < logs/analysis/kr-candidates-for-conversion.txt) candidates"

# Fix 3: Add missing function prototypes
echo "[3/5] Detecting missing prototypes..."
# (Detection phase)

# Fix 4: Fix common type issues
echo "[4/5] Fixing common type issues..."
# (Start with detection)

# Fix 5: Add missing includes for standard functions
echo "[5/5] Adding standard includes..."
# string.h, stdlib.h, stdio.h as needed

echo ""
echo "✅ Automated fixes complete"
echo "   Review changes with: git diff"
```

#### Afternoon Tasks (4 hours)

**Task 3: CI/CD Integration** (3 hours)

Update `.github/workflows/c17-compliance.yml`:
```yaml
name: C17 Compliance Check

on: [push, pull_request]

jobs:
  c17-check:
    runs-on: ubuntu-24.04

    steps:
    - uses: actions/checkout@v4

    - name: Install dependencies
      run: |
        sudo apt update
        sudo apt install -y clang-15 bmake

    - name: Check header guards
      run: |
        # Verify all headers have guards
        TOTAL=$(find usr/src -name "*.h" | wc -l)
        WITH_GUARDS=$(find usr/src -name "*.h" -exec grep -l "#ifndef.*_H" {} \; | wc -l)
        PERCENT=$((WITH_GUARDS * 100 / TOTAL))

        echo "Header guard coverage: $PERCENT%"

        if [ $PERCENT -lt 90 ]; then
          echo "ERROR: Header guard coverage below 90%"
          exit 1
        fi

    - name: C17 compilation check (allow failures for now)
      continue-on-error: true
      run: |
        cd usr/src
        make CC=clang CFLAGS="-std=c17 -pedantic" 2>&1 | \
          tee ../logs/build/c17-ci-check.log || true

    - name: Upload logs
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: c17-check-logs
        path: logs/
```

**Task 4: Documentation Updates** (1 hour)

Update all docs with Week 2 findings:
- Update roadmap with actual timelines
- Update requirements.md with discovered needs
- Update README.md with current status

**Deliverables**:
- [ ] Enhanced analysis scripts
- [ ] Migration helper scripts (initial versions)
- [ ] CI/CD integration
- [ ] Updated documentation

---

## Week 3: Prioritized Fixes (Days 11-15)

**Goal**: Fix highest-priority blockers discovered in Week 2

### Day 11-12: P0 Critical Fixes

**Focus**: Issues that block all other work

**Candidates** (based on anticipated findings):
1. Missing critical system headers
2. Build system configuration issues
3. Toolchain incompatibilities

**Process**:
```bash
# Each fix follows this pattern:
1. Identify issue from tracker
2. Create branch: fix/issue-ID
3. Implement fix
4. Test: does it compile further?
5. Commit with reference to issue
6. Merge to main branch
```

### Day 13-14: High-Impact Quick Wins

**Focus**: Fixes that improve many files at once

**Examples**:
- Add missing standard includes (automated)
- Fix common type definition issues
- Standardize header include patterns

**Expected**: 100-200 files improved

### Day 15: Validation & Documentation

**Tasks**:
- Re-run C17 build (expect fewer errors)
- Document improvements
- Update metrics
- Prepare Week 3 report

---

## Week 4: Phase 1 Preparation (Days 16-20)

**Goal**: Detailed planning for Phase 1 execution

### Day 16-17: Subsystem Analysis

**Task**: Choose subsystems for Phase 1 migration

**Analysis Criteria**:
1. **Size**: Smaller is better (faster completion)
2. **Independence**: Fewer dependencies
3. **Impact**: High visibility/importance
4. **Difficulty**: Start easier, build confidence

**Candidates**:
- `bin/` utilities (small, independent)
- `lib/libc/string/` (contained, well-defined)
- `kernel/ddb/` (debugger - isolated)

**Deliverable**: Subsystem selection matrix

### Day 18: Phase 1 Detailed Planning

Create `docs/PHASE_1_EXECUTION_PLAN.md`:

**Structure**:
```markdown
# Phase 1: Core Migration - Detailed Execution Plan

## Overview
Duration: 3 months
Goal: Migrate selected subsystems to C17

## Month 1: [Subsystem 1]
- Week 1: K&R to ANSI conversion
- Week 2: Type modernization
- Week 3: Testing and validation
- Week 4: Documentation and handoff

## Month 2: [Subsystem 2]
...

## Month 3: [Subsystem 3]
...

## Success Criteria
- All selected subsystems compile with -std=c17
- Zero new warnings introduced
- All tests pass
- Documentation complete
```

### Day 19: Testing Infrastructure

**Create**:
1. Test framework for validation
2. Regression test suite
3. Performance benchmarks baseline

**Tools**:
- Unit test harness
- Integration test scripts
- Automated test runner

### Day 20: Phase 0 Completion

**Tasks**:
1. Final metrics collection
2. Phase 0 completion report
3. Phase 0 → Phase 1 handoff document
4. Team review and approval

---

## Success Criteria for Weeks 2-4

### Week 2: Baseline Establishment
- [ ] C17 build attempted and documented
- [ ] Static analysis baseline complete
- [ ] Master baseline report written
- [ ] All tools enhanced and working

### Week 3: Prioritized Fixes
- [ ] All P0 issues resolved
- [ ] 5+ high-impact fixes implemented
- [ ] Measurable improvement in C17 compliance
- [ ] All fixes tested and committed

### Week 4: Phase 1 Preparation
- [ ] Subsystems selected for Phase 1
- [ ] Phase 1 detailed plan complete
- [ ] Testing infrastructure ready
- [ ] Team approved to proceed

---

## Risk Management

### Identified Risks

| Risk | Probability | Impact | Mitigation |
|------|------------|--------|------------|
| C17 build finds too many errors | High | Medium | Expected; document, prioritize |
| Static analysis takes too long | Medium | Low | Run overnight, subset if needed |
| Tools need debugging | Medium | Medium | Allocate debug time, have fallbacks |
| Scope creep in fixes | High | Medium | Strict P0/P1 only in Week 3 |

### Contingency Plans

**If C17 errors > 10,000**:
- Focus on top 10 error categories
- Defer rest to Phase 1
- Adjust Phase 1 timeline

**If static analysis incomplete**:
- Run on subset (kernel only first)
- Complete remainder later
- Don't block progress

**If Week 3 fixes take too long**:
- Defer non-critical fixes
- Focus on P0 only
- Extend Week 3 by 2-3 days if needed

---

## Daily Standup Template

```markdown
## Daily Standup - Phase 0, Day X

**Date**: YYYY-MM-DD
**Week**: X

### Completed Yesterday
- [ ] Task 1
- [ ] Task 2

### Planned Today
- [ ] Task 1
- [ ] Task 2

### Blockers
- None / [Describe blocker]

### Metrics
- C17 errors: X → Y (improvement: Z)
- Issues fixed: N
- Time spent: H hours
```

---

## Deliverables Checklist

### Week 2 Deliverables
- [ ] C17 baseline build logs
- [ ] C17 error analysis (CSV + report)
- [ ] Static analysis results
- [ ] Master baseline report
- [ ] Enhanced automation scripts
- [ ] CI/CD integration

### Week 3 Deliverables
- [ ] P0 fixes committed
- [ ] High-impact fixes committed
- [ ] Updated metrics showing improvement
- [ ] Week 3 completion report

### Week 4 Deliverables
- [ ] Subsystem selection document
- [ ] Phase 1 detailed execution plan
- [ ] Testing infrastructure
- [ ] Phase 0 completion report
- [ ] Phase 0 → Phase 1 handoff

---

## Next Steps After This Plan

**Immediate** (Today):
```bash
# Start Day 6: C17 baseline build
cd /home/user/386bsd
./scripts/[prepare for C17 build]
```

**This Week**:
- Execute Days 6-10 per this plan
- Update todos daily
- Commit progress regularly

**Next 2 Weeks**:
- Execute Weeks 3-4
- Monitor against plan
- Adjust as needed

---

**Document Version**: 1.0
**Created**: 2025-11-19
**Status**: Ready for Execution
**Estimated Total Time**: 80-100 hours over 3 weeks

**AD ASTRA PER MATHEMATICA ET SCIENTIAM**
