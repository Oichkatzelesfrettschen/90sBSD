# 386BSD Documentation Index

**Welcome to the 386BSD documentation repository.** This directory contains comprehensive documentation for the 386BSD operating system modernization project.

---

## Quick Navigation

### 🚀 Getting Started
- [**Main README**](../README.md) - Project overview and quick start
- [**Build Requirements**](build/requirements.md) - Complete setup guide
- [**Installation Guide**](build/INSTALL.md) - Installation instructions

### 📋 Standards and Roadmaps
- [**Alternate History Evolution**](standards/ALTERNATE_HISTORY_EVOLUTION.md) - Visionary framework for modernization
- [**C17/SUSv4 Roadmap**](standards/C17_SUSV4_ROADMAP.md) - Practical implementation guide
- [**Comprehensive Audit Report**](standards/COMPREHENSIVE_AUDIT_REPORT.md) - Current state analysis

### 🔧 Build System
- [**Requirements**](build/requirements.md) - Tools and dependencies
- [**Build Issues**](build/BUILD_ISSUES.md) - Troubleshooting guide
- [**Setup Guide**](build/setup.md) - Detailed setup instructions

### 📚 Architecture and Design
- [**Codebase Segmentation**](codebase-segmentation.rst) - Code organization
- [**Header Audit**](header-audit.md) - Header file analysis
- [**Tooling Report**](tooling-report.md) - Development tools overview
- [**Sysroot Documentation**](sysroot.md) - Cross-compilation sysroot

### 🗂️ Legacy & Historical Archives
- [**Legacy Documents**](legacy/) - Original documents from 386BSD
- [**Historical Archives**](history/) - Detailed progress reports from the modernization project

### 📖 Guides and How-Tos
- [**Repository Hygiene**](guides/REPOSITORY_HYGIENE.md) - Repository maintenance
- [**Reproducible Build**](reproducible-build.md) - Build reproducibility

---

## Documentation Structure

```
docs/
├── README.md                    ← You are here
│
├── standards/                   ← Standards and roadmaps
│   ├── ALTERNATE_HISTORY_EVOLUTION.md
│   ├── C17_SUSV4_ROADMAP.md
│   └── COMPREHENSIVE_AUDIT_REPORT.md
│
├── build/                       ← Build system documentation
│   ├── requirements.md          ← Complete requirements (PRIMARY)
│   ├── BUILD_ISSUES.md          ← Troubleshooting
│   ├── INSTALL.md               ← Installation guide
│   └── setup.md                 ← Detailed setup
│
├── architecture/                ← System architecture
│   └── (to be populated)
│
├── api/                         ← API documentation
│   └── (Doxygen output - generated)
│
├── guides/                      ← User guides and how-tos
│   └── REPOSITORY_HYGIENE.md
│
├── legacy/                      ← Historical documents
│   ├── CONTRIB.TXT
│   ├── COPYRGHT.TXT
│   ├── INFO.TXT
│   ├── RELEASE.TXT
│   └── SOFTSUB.TXT
│
└── [Supporting files]
    ├── codebase-segmentation.rst
    ├── header-audit.md
    ├── include-audit.md
    ├── reproducible-build.md
    ├── sysroot.md
    └── tooling-report.md
```

---

## Documentation by Purpose

### For New Contributors
1. Start with [Main README](../README.md)
2. Review [Build Requirements](build/requirements.md)
3. Read [Alternate History Evolution](standards/ALTERNATE_HISTORY_EVOLUTION.md) for vision
4. Study [C17/SUSv4 Roadmap](standards/C17_SUSV4_ROADMAP.md) for implementation plan

### For Developers
1. [Build Requirements](build/requirements.md) - Set up your environment
2. [Build Issues](build/BUILD_ISSUES.md) - Solve build problems
3. [Comprehensive Audit](standards/COMPREHENSIVE_AUDIT_REPORT.md) - Understand current state
4. [Tooling Report](tooling-report.md) - Development tools

### For Project Managers
1. [Comprehensive Audit](standards/COMPREHENSIVE_AUDIT_REPORT.md) - Current state
2. [C17/SUSv4 Roadmap](standards/C17_SUSV4_ROADMAP.md) - Implementation timeline

### For Researchers
1. [Alternate History Evolution](standards/ALTERNATE_HISTORY_EVOLUTION.md) - Theoretical framework
2. [Legacy Documents](legacy/) - Historical context
3. [Codebase Segmentation](codebase-segmentation.rst) - Code organization

---

## Key Documents Explained

### Standards Documentation

#### **Alternate History Evolution** (Visionary)
A unique counterfactual analysis imagining how 386BSD could have evolved independently from the 1990s through today, culminating in C17/SUSv4 compliance. This document provides:
- Historical divergence points
- Technical evolution layers (C89 → C99 → C11 → C17)
- Unique architectural innovations (capability system, zero-copy I/O)
- Design patterns for modern BSD

**Purpose**: Provides philosophical and technical foundation for modernization decisions.

#### **C17/SUSv4 Roadmap** (Practical)
The actionable implementation guide for achieving C17 and POSIX.1-2017 compliance.
- 5-phase implementation plan (18 months)
- Concrete tasks with timelines
- Tool requirements and scripts
- Success criteria and validation

**Purpose**: Day-to-day guide for implementation work.

#### **Comprehensive Audit Report** (Analysis)
Detailed analysis of the current repository state, including:
- 1.09 million LOC analysis
- Standards compliance gaps
- Code quality metrics
- Priority issues and recommendations

**Purpose**: Baseline assessment and gap analysis.

### Build Documentation

#### **Requirements.md** (PRIMARY)
Complete guide to tools, dependencies, and setup for 386BSD development.
- System requirements
- Compiler toolchain (Clang 15+)
- Build tools (BMAKE, CMake)
- Static analysis tools
- Module-specific requirements

**Purpose**: Authoritative requirements reference.

#### **BUILD_ISSUES.md**
Troubleshooting guide for common build problems.

#### **setup.md**
Detailed setup walkthrough.

---

## Contributing to Documentation

### Adding New Documentation

1. **Choose the right directory**:
   - `standards/` - Standards, roadmaps, analyses
   - `build/` - Build system, setup, troubleshooting
   - `architecture/` - System design, architecture
   - `api/` - API documentation (generated)
   - `guides/` - How-tos, tutorials
   - `legacy/` - Historical documents (append-only)

2. **Use Markdown** (.md) for most documentation
   - Use reStructuredText (.rst) only if Sphinx is required

3. **Follow naming conventions**:
   - `UPPERCASE_WITH_UNDERSCORES.md` for major documents
   - `lowercase-with-dashes.md` for supporting files

4. **Update this index** when adding major documents

5. **Cross-reference** related documents

### Documentation Standards

- **Clear headings** - Use hierarchical structure (## Part, ### Section)
- **Code examples** - Always include runnable examples
- **Tables** - Use for comparisons and checklists
- **Links** - Link to related documents
- **Date stamping** - Include creation/update dates
- **Version control** - Track document versions

---

## Tools for Documentation

### Markdown
Most documentation uses GitHub-flavored Markdown.

### Doxygen
API documentation generated from source code comments.

**Generate**:
```bash
cd docs
doxygen Doxyfile.in
# Output in api/
```

### Sphinx (Optional)
For advanced documentation builds.

```bash
cd docs
sphinx-build -b html . _build/html
```

---

## Maintenance

This documentation is maintained by the 386BSD Modernization Team.

**Update Frequency**:
- **Standards docs**: Updated at phase completions
- **Build docs**: Updated as requirements change
- **API docs**: Regenerated on each release
- **Audit reports**: Periodic re-audits

**Contact**: See main [README.md](../README.md) for maintainer information.

---

## Additional Resources

### External Links
- [C17 Standard (Wikipedia)](https://en.wikipedia.org/wiki/C17_(C_standard_revision))
- [POSIX.1-2017 (Open Group)](https://pubs.opengroup.org/onlinepubs/9699919799/)
- [386BSD History (Crystallabs)](https://crystallabs.io/unix-history/)
- [BSD History (Spinellis)](https://github.com/dspinellis/unix-history-repo)

### Related Repositories
- [FreeBSD](https://www.freebsd.org/) - Modern BSD descendant
- [NetBSD](https://www.netbsd.org/) - Portable BSD descendant
- [OpenBSD](https://www.openbsd.org/) - Security-focused BSD descendant

---

**Last Updated**: 2025-11-19
**Version**: 1.0
**Maintainers**: 386BSD Modernization Team
