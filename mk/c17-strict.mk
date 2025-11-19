# ---------------------------------------------------------------------------
# mk/c17-strict.mk
#
# BSD make profile for C17 strict compliance enforcement
# Use this profile to enable full C17 standard compliance with strict
# warnings and error checking.
#
# Usage:
#   bmake -f Makefile.c17 PROFILE=c17-strict <target>
#
# Or include in your Makefile:
#   .include "mk/c17-strict.mk"
#
# Based on: mk/clang-elf.mk
# Enhanced: C17 compliance + strict warnings
# ---------------------------------------------------------------------------

# Inherit from clang-elf.mk if it exists
.if exists(${.CURDIR}/mk/clang-elf.mk)
.include "mk/clang-elf.mk"
.endif

# Ensure we're using modern Clang
.if !defined(CC) || ${CC:M*clang*} == ""
CC=clang
.endif

# ---------------------------------------------------------------------------
# C17 Standard Compliance
# ---------------------------------------------------------------------------

# C Standard: ISO/IEC 9899:2018 (C17)
CSTD_FLAGS= -std=c17 -pedantic

# Make warnings into errors (quality gate)
WERROR_FLAGS= -Werror

# ---------------------------------------------------------------------------
# Comprehensive Warning Flags
# ---------------------------------------------------------------------------

# Core warnings (high signal-to-noise)
WARN_CORE= \
	-Wall \
	-Wextra \
	-Wshadow \
	-Wformat=2 \
	-Wformat-security

# C-specific warnings
WARN_C= \
	-Wstrict-prototypes \
	-Wold-style-definition \
	-Wmissing-prototypes \
	-Wmissing-declarations \
	-Wimplicit-function-declaration \
	-Wpointer-arith \
	-Wcast-align \
	-Wcast-qual

# Type safety warnings
WARN_TYPES= \
	-Wconversion \
	-Wsign-conversion \
	-Wfloat-equal \
	-Wstrict-overflow=2

# Code quality warnings
WARN_QUALITY= \
	-Wunused \
	-Wuninitialized \
	-Wundef \
	-Wredundant-decls \
	-Wwrite-strings

# UB and undefined behavior warnings
WARN_UB= \
	-Wsequence-point \
	-Wtrigraphs \
	-Wdiv-by-zero

# Commonly disabled warnings (too noisy for legacy code)
WARN_SUPPRESS= \
	-Wno-unused-parameter \
	-Wno-missing-field-initializers \
	-Wno-gnu-zero-variadic-macro-arguments

# Combine all warnings
WARN_FLAGS= \
	${WARN_CORE} \
	${WARN_C} \
	${WARN_TYPES} \
	${WARN_QUALITY} \
	${WARN_UB} \
	${WARN_SUPPRESS}

# ---------------------------------------------------------------------------
# Static Analysis Integration
# ---------------------------------------------------------------------------

# Enable clang static analyzer (optional, controlled by ANALYZE=1)
.if defined(ANALYZE) && ${ANALYZE} == "1"
ANALYZE_FLAGS= --analyze -Xanalyzer -analyzer-output=text
.else
ANALYZE_FLAGS=
.endif

# ---------------------------------------------------------------------------
# Sanitizers (controlled by SANITIZE variable)
# ---------------------------------------------------------------------------

# SANITIZE=address    - AddressSanitizer (memory errors)
# SANITIZE=undefined  - UndefinedBehaviorSanitizer (UB detection)
# SANITIZE=thread     - ThreadSanitizer (race conditions)
# SANITIZE=all        - ASan + UBSan (cannot combine with TSan)

.if defined(SANITIZE)
.  if ${SANITIZE} == "address"
SANITIZE_FLAGS= -fsanitize=address -fno-omit-frame-pointer -g
.  elif ${SANITIZE} == "undefined"
SANITIZE_FLAGS= -fsanitize=undefined -fno-omit-frame-pointer -g
.  elif ${SANITIZE} == "thread"
SANITIZE_FLAGS= -fsanitize=thread -fno-omit-frame-pointer -g
.  elif ${SANITIZE} == "all"
SANITIZE_FLAGS= -fsanitize=address,undefined -fno-omit-frame-pointer -g
.  else
.    error "Unknown SANITIZE value: ${SANITIZE}. Use: address, undefined, thread, or all"
.  endif
.else
SANITIZE_FLAGS=
.endif

# ---------------------------------------------------------------------------
# Optimization and Debug
# ---------------------------------------------------------------------------

# Default optimization level (override with OPTLEVEL=)
OPTLEVEL?= -O2

# Debug symbols (always include for better diagnostics)
DEBUG_FLAGS= -g

# Link-time optimization (optional, controlled by LTO=1)
.if defined(LTO) && ${LTO} == "1"
LTO_FLAGS= -flto
.else
LTO_FLAGS=
.endif

# ---------------------------------------------------------------------------
# Combined CFLAGS
# ---------------------------------------------------------------------------

# Build the complete CFLAGS
# Priority order:
#   1. Standard compliance (CSTD_FLAGS)
#   2. Warnings (WARN_FLAGS + WERROR_FLAGS)
#   3. Optimization (OPTLEVEL)
#   4. Debug symbols (DEBUG_FLAGS)
#   5. Sanitizers (SANITIZE_FLAGS)
#   6. Analysis (ANALYZE_FLAGS)
#   7. LTO (LTO_FLAGS)
#   8. Platform-specific (from clang-elf.mk if included)
#   9. User overrides (EXTRA_CFLAGS)

export CFLAGS= \
	${CSTD_FLAGS} \
	${WARN_FLAGS} \
	${WERROR_FLAGS} \
	${OPTLEVEL} \
	${DEBUG_FLAGS} \
	${SANITIZE_FLAGS} \
	${ANALYZE_FLAGS} \
	${LTO_FLAGS} \
	${COMMON_CFLAGS} \
	${EXTRA_CFLAGS}

# ---------------------------------------------------------------------------
# Linker Flags for Sanitizers
# ---------------------------------------------------------------------------

.if defined(SANITIZE)
export LDFLAGS += ${SANITIZE_FLAGS}
.endif

.if defined(LTO) && ${LTO} == "1"
export LDFLAGS += ${LTO_FLAGS}
.endif

# ---------------------------------------------------------------------------
# Feature Test Macros for C17 + POSIX.1-2017
# ---------------------------------------------------------------------------

# POSIX.1-2017 compliance
POSIX_FLAGS= -D_POSIX_C_SOURCE=200809L

# X/Open System Interfaces (SUSv4)
XOPEN_FLAGS= -D_XOPEN_SOURCE=700

# BSD extensions (when needed)
.if defined(NEED_BSD_EXTENSIONS) && ${NEED_BSD_EXTENSIONS} == "1"
BSD_FLAGS= -D_BSD_SOURCE -D_DEFAULT_SOURCE
.else
BSD_FLAGS=
.endif

# Add feature test macros to CPPFLAGS
export CPPFLAGS += ${POSIX_FLAGS} ${XOPEN_FLAGS} ${BSD_FLAGS}

# ---------------------------------------------------------------------------
# Validation Targets
# ---------------------------------------------------------------------------

# Target to verify C17 compliance
.PHONY: verify-c17
verify-c17:
	@echo "Verifying C17 compliance..."
	@echo "Compiler: ${CC}"
	@${CC} --version
	@echo "CFLAGS: ${CFLAGS}"
	@echo "Testing C17 support..."
	@echo 'int main(void) { return 0; }' | \
		${CC} ${CFLAGS} -x c - -o /tmp/test_c17 && \
		echo "✓ C17 compilation successful" || \
		echo "✗ C17 compilation failed"
	@rm -f /tmp/test_c17

# Target to show all flags
.PHONY: show-flags
show-flags:
	@echo "C17 Strict Mode Flags"
	@echo "====================="
	@echo ""
	@echo "CC:       ${CC}"
	@echo "CFLAGS:   ${CFLAGS}"
	@echo "CPPFLAGS: ${CPPFLAGS}"
	@echo "LDFLAGS:  ${LDFLAGS}"
	@echo ""
	@echo "Components:"
	@echo "  CSTD_FLAGS:      ${CSTD_FLAGS}"
	@echo "  WARN_FLAGS:      ${WARN_FLAGS}"
	@echo "  WERROR_FLAGS:    ${WERROR_FLAGS}"
	@echo "  OPTLEVEL:        ${OPTLEVEL}"
	@echo "  DEBUG_FLAGS:     ${DEBUG_FLAGS}"
	@echo "  SANITIZE_FLAGS:  ${SANITIZE_FLAGS}"
	@echo "  ANALYZE_FLAGS:   ${ANALYZE_FLAGS}"
	@echo "  LTO_FLAGS:       ${LTO_FLAGS}"

# ---------------------------------------------------------------------------
# Usage Examples
# ---------------------------------------------------------------------------

# Example 1: Build with C17 strict mode
#   bmake -f Makefile PROFILE=c17-strict
#
# Example 2: Build with AddressSanitizer
#   bmake -f Makefile PROFILE=c17-strict SANITIZE=address
#
# Example 3: Build with static analysis
#   bmake -f Makefile PROFILE=c17-strict ANALYZE=1
#
# Example 4: Build with LTO
#   bmake -f Makefile PROFILE=c17-strict LTO=1
#
# Example 5: Aggressive optimization
#   bmake -f Makefile PROFILE=c17-strict OPTLEVEL=-O3
#
# Example 6: Include BSD extensions
#   bmake -f Makefile PROFILE=c17-strict NEED_BSD_EXTENSIONS=1

# ---------------------------------------------------------------------------
# Notes
# ---------------------------------------------------------------------------

# This configuration enforces:
# ✓ C17 standard compliance (ISO/IEC 9899:2018)
# ✓ POSIX.1-2017 compliance (IEEE Std 1003.1-2017)
# ✓ Comprehensive warnings (-Wall -Wextra and more)
# ✓ Treat warnings as errors (-Werror)
# ✓ Optional sanitizers for runtime checking
# ✓ Optional static analysis integration
# ✓ Optional link-time optimization
#
# Known limitations:
# - Some legacy code may not compile immediately
# - May need gradual migration (file-by-file)
# - Sanitizers add runtime overhead (use for testing, not production)
# - Cannot combine ASan with TSan (use separately)
#
# Migration strategy:
# 1. Build with this profile to identify issues
# 2. Fix warnings file-by-file
# 3. Gradually reduce WARN_SUPPRESS list
# 4. Eventually make this the default profile

# ---------------------------------------------------------------------------
# Metadata
# ---------------------------------------------------------------------------

# Profile Version: 1.0
# Created: 2025-11-19
# For: 386BSD C17/SUSv4 Modernization Project
# Maintainer: 386BSD Modernization Team
