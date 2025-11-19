DAY 16 EXECUTION STRATEGY - 3-ERROR FILES
==========================================
Date: 2025-11-19
Target: 61 files with exactly 3 errors
Goal: +24 files passing (40% success rate)
Projected: 948 → 972 files (43.9%)

STRATEGIC BREAKDOWN
===================

Total 3-Error Files: 61
├── Single Category: 30 files (PHASE 1 - HIGH PRIORITY)
│   ├── implicit_function: 21 files (63 errors)
│   ├── other: 4 files (12 errors) [SKIP - needs analysis]
│   ├── undeclared_identifier: 3 files (9 errors)
│   └── kr_function: 2 files (6 errors)
│
└── Mixed Category: 31 files (PHASE 2 - MODERATE PRIORITY)
    ├── implicit_function + kr_function: 17 files
    ├── kr_function + other: 5 files
    ├── implicit_function + other: 2 files
    ├── implicit_function + undeclared_identifier: 2 files
    └── other combinations: 5 files

PHASE 1: SINGLE-CATEGORY FILES (26 files)
==========================================

Phase 1A: Implicit Function (21 files)
---------------------------------------
Target: 21 files with 3 implicit_function errors each
Tool: fix-implicit-functions-batch.py (enhanced, 80+ mappings)
Expected: +12-15 files passing (~60% success rate)

Strategy:
1. Extract file list from analysis
2. Apply batch fixer with comprehensive function mappings
3. Handle unknown functions (document for manual review)
4. Validate with scan

Files Preview:
- usr/src/games/hangman/main.c
- usr/src/kernel/ddb/db_expr.c, db_print.c
- usr/src/lib/libc/gen/glob.c
- usr/src/lib/libc/stdio/printf.c, fpurge.c
- usr/src/usr.bin/* (multiple)

Phase 1B: K&R Function (2 files)
---------------------------------
Target: 2 files with 3 kr_function errors each
Tool: fix-kr-functions-multi.py
Expected: +2 files passing (~100% success rate)

Files:
- usr/src/bin/ed/cbc.c
- usr/src/lib/libc/stdio/stdio.c

Phase 1C: Undeclared Identifier (3 files)
------------------------------------------
Target: 3 files with 3 undeclared_identifier errors each
Tool: fix-undeclared-identifiers.py
Expected: +1-2 files passing (~50% success rate)

Files:
- usr/src/lib/libcurses/getch.c
- usr/src/usr.bin/strip/strip.c
- usr/src/usr.bin/tn3270/tools/mkdstoas.c

Phase 1 Total Expected: +15-19 files

PHASE 2: MIXED-CATEGORY FILES (17 files)
=========================================

Phase 2A: Impl + KR Combo (17 files)
-------------------------------------
Target: 17 files with implicit_function + kr_function errors
Tools: fix-implicit-functions-batch.py + fix-kr-functions-multi.py
Expected: +5-8 files passing (~35% success rate)

Strategy:
1. Fix implicit_function errors first (add headers)
2. Fix kr_function errors second (add return types)
3. Clean up duplicates
4. Validate

Expected Outcome:
- Some files: 3 → 0 errors (pass)
- Some files: 3 → 1-2 errors (progress)
- Some files: Unknown functions block complete fix

Phase 2 Total Expected: +5-8 files

EXECUTION ORDER
===============

Morning (Phase 1A):
1. Extract 21 implicit_function file list
2. Run batch fixer
3. Document unknown functions
4. Validate with intermediate scan
5. Commit Phase 1A

Mid-Day (Phase 1B + 1C):
6. Fix 2 kr_function files
7. Fix 3 undeclared_identifier files
8. Clean duplicates
9. Validate
10. Commit Phase 1B+1C

Afternoon (Phase 2A):
11. Extract 17 impl+kr combo files
12. Apply combined fixes
13. Clean duplicates
14. Final validation
15. Commit Phase 2A

Evening (Wrap-up):
16. Run comprehensive C17 scan
17. Analyze results vs projections
18. Create Day 16 completion report
19. Push all commits

SUCCESS METRICS
===============

Minimum Success (Conservative):
- +20 files passing
- 948 → 968 files (43.7%)
- -60+ errors

Target Success (Expected):
- +24 files passing
- 948 → 972 files (43.9%)
- -75+ errors

Stretch Success (Optimistic):
- +30 files passing
- 948 → 978 files (44.1%)
- -90+ errors

RISK MITIGATION
================

Risk 1: Unknown Functions in Implicit_Function Files
- Mitigation: Document for manual review
- Fallback: Partial fixes still reduce error count

Risk 2: 3 Errors May Have Hidden 4th Error
- Mitigation: Validate frequently
- Recovery: Unmasking expected, budget 30-40% loss

Risk 3: "Other" Category Remains Complex
- Mitigation: Skip "other" single-category files (4 files)
- Focus: High-confidence categories only

TOOLS READY
============

Existing Tools (Proven):
✓ fix-implicit-functions-batch.py (80+ mappings)
✓ fix-kr-functions-multi.py (multi-function support)
✓ fix-undeclared-identifiers.py (identifier mapping)
✓ fix-duplicate-return-types.py (cleanup)
✓ analyze-c17-compliance.py (validation)

No New Tools Needed:
- Reuse Day 15 automation
- Leverage proven patterns
- Scale up to 3-error complexity

EXECUTION READINESS
===================

Prerequisites: ✅ All met
- Current state: 948 files (42.8%)
- Tools: Ready and tested
- Strategy: Clear and phased
- Validation: C17 scanner ready

Go/No-Go Decision: ✅ GO

Confidence Level: HIGH
- Based on Day 15 success (47 files → 23 passing)
- Single-category success rate: 66%
- Tools proven and reliable
- Phased approach allows course correction

PROCEED TO EXECUTION
====================

Next: Phase 1A - Fix 21 implicit_function 3-error files

---
Status: Strategy Complete, Ready for Execution
Time: Day 16 AM Start
