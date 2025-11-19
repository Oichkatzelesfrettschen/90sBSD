WEEK 4 STRATEGIC ROADMAP
========================
Date: 2025-11-19
Phase: Phase 0, Week 4 (Days 15-18)
Starting: 41% (925/2,215 files)
Target: 50-55% (1,108-1,218 files)
Required: +183-293 files

STRATEGIC VISION
================

Building on Week 3's success with single-error file targeting, Week 4 will
employ a "graduated difficulty" approach:

1. Files with 2 errors (92 files) → Easier, highest ROI
2. Files with 3 errors (61 files) → Moderate difficulty
3. Files with 4-5 errors (111 files) → Backup targets

Target: Fix 153 files (2-3 errors) → 1,078 files passing (48.7%)
Stretch: Fix 264 files (2-5 errors) → 1,189 files passing (53.7%)

OPPORTUNITY ANALYSIS
====================

Files with 2-3 Errors: 153 files
---------------------------------

Error Combination Analysis:
  39 files: implicit_function only
  35 files: implicit_function + kr_function
  21 files: undeclared_identifier only
  14 files: kr_function only
  11 files: other only
   8 files: implicit_function + other
   8 files: kr_function + other
  17 files: various other combinations

Fix Approach Priority:
1. Single-category errors (39 + 21 + 14 + 11 = 85 files) → EASIEST
2. Two-category combos (35 + 8 + 8 = 51 files) → MODERATE
3. Three+ category combos (17 files) → COMPLEX

WEEK 4 DAY-BY-DAY PLAN
=======================

Day 15 (TODAY): 2-Error Files with Single Categories
-----------------------------------------------------
Target: 92 files with 2 errors
Focus: Files where both errors are same category
Strategy: Apply proven Week 3 tools

Morning (3-4 hours):
- Analyze 2-error files by category
- Identify single-category duplicates
- Apply fix-implicit-functions.py
- Apply fix-kr-functions-with-inference.py

Afternoon (2-3 hours):
- Fix undeclared_identifier files (add includes)
- Fix "other" category files (case-by-case)
- Run C17 scan
- Measure impact

Expected: +50-70 files passing (41% → 44-45%)

Day 16: 2-Error Files with Mixed Categories
--------------------------------------------
Target: Remaining 2-error files (~30-40 files)
Focus: Files with 2 different error categories
Strategy: Combined fixes (header + K&R, etc.)

Approach:
- implicit_function + kr_function → add header + fix return type
- kr_function + other → case-by-case analysis
- implicit_function + other → add header + investigate

Expected: +20-30 files passing (44-45% → 46-47%)

Day 17: 3-Error Files
---------------------
Target: 61 files with 3 errors
Focus: Triple fixes (more complex)
Strategy: Systematic multi-issue resolution

Approach:
- Analyze error patterns
- Create combined fix scripts
- Test incrementally
- Validate thoroughly

Expected: +30-40 files passing (46-47% → 48-50%)

Day 18: 4-5 Error Files (Stretch Goal)
---------------------------------------
Target: 111 files with 4-5 errors
Focus: Push beyond 50% target
Strategy: High-value, lower-hanging fruit only

Approach:
- Identify files with fixable error patterns
- Apply combined tooling
- Manual review for edge cases

Expected: +20-40 files passing (48-50% → 50-52%)

TOOLING ENHANCEMENTS
====================

New Tools Needed:
1. fix-undeclared-identifiers.py
   - Map common undefined symbols to headers
   - Similar to fix-implicit-functions.py
   - Auto-add includes for system calls, types

2. combined-fixer.py
   - Multi-issue fixer for mixed-category files
   - Orchestrates existing tools
   - Handles dependencies (e.g., header before prototype)

3. analyze-other-category.py
   - Classify "other" errors into subcategories
   - Identify fixable vs manual-review
   - Create fix recommendations

Enhanced Tools:
- fix-implicit-functions.py
  - Expand function→header mapping
  - Add more system headers
  - Better positioning logic

- fix-kr-functions-with-inference.py
  - Handle more complex return types
  - Better parameter inference
  - Edge case handling

RISK MITIGATION
================

Risk 1: Multi-Issue Files Have Dependencies
- Mitigation: Fix in correct order (headers → types → functions)
- Validation: Re-scan after each batch

Risk 2: "Other" Category May Be Complex
- Mitigation: Sample first, categorize, then fix
- Fallback: Skip most complex, focus on easy wins

Risk 3: Automation May Miss Edge Cases
- Mitigation: Sample validation before broad application
- Recovery: Duplicate-fixer-style cleanup scripts

Risk 4: Unmasking Effect May Increase
- Mitigation: Expected and acceptable
- Focus: Net error reduction + pass rate increase

SUCCESS METRICS
===============

Minimum Success (50% target):
- +183 files passing minimum
- 1,108/2,215 files (50.0%)
- -1,500+ errors

Target Success (52% mid-range):
- +230 files passing
- 1,155/2,215 files (52.1%)
- -2,000+ errors

Stretch Success (55% upper bound):
- +293 files passing
- 1,218/2,215 files (55.0%)
- -2,500+ errors

EXECUTION PRINCIPLES
====================

1. Graduated Difficulty
   - Start easy (single-category, 2 errors)
   - Progress to moderate (mixed-category, 2 errors)
   - Advance to complex (3+ errors)

2. Validate Frequently
   - Scan after each major batch
   - Catch issues early
   - Adjust strategy based on results

3. Leverage Week 3 Tools
   - Reuse proven scripts
   - Enhance rather than rewrite
   - Build on successful patterns

4. Document Thoroughly
   - Granular TODO tracking
   - Daily summaries
   - Final comprehensive report

5. Maintain Quality
   - Zero regressions
   - Clean git history
   - Comprehensive testing

WEEK 4 DELIVERABLES
===================

Code Changes:
- 150-300 source files modified
- 3-5 new/enhanced automation tools
- 8-12 git commits

Documentation:
- Daily analysis reports (Days 15-18)
- WEEK_4_COMPLETE.md
- 30+ analysis data files
- ~10,000 words documentation

Validation:
- C17 scans after each day
- Regression testing
- Build validation
- Git history review

CONTINGENCY PLANS
==================

If Behind Schedule:
- Focus on 2-error files only
- Use only proven tools
- Skip "other" category complexities
- Still achieve 50% minimum

If Ahead of Schedule:
- Tackle 4-5 error files
- Push toward 55% stretch goal
- Create advanced tooling
- Document extra lessons learned

If Unexpected Issues:
- Revert to last known good state
- Analyze root cause
- Adjust strategy
- Validate before proceeding

CONCLUSION
==========

Week 4 employs the proven "low-error file targeting" strategy from Week 3
Day 14, but scales it up to files with 2-3 errors. This graduated approach
maximizes pass rate increase while managing complexity.

With 153 target files (2-3 errors), achieving 50-55% is highly feasible.
The tooling infrastructure from Week 3 provides a solid foundation, and
the error category understanding enables strategic fixes.

Expected outcome: 50-52% pass rate (conservative), 52-55% (optimistic)

---
Status: Ready for execution
Confidence: HIGH
Go/No-Go: GO ✅

Next: Day 15 execution begins
