# Repository Hygiene

This repository originally contained several prebuilt binary files including
`386bsd`, `386bsd.ddb`, `386bsd.small`, and numerous executables stored under
`usr/local/`. Retaining these binaries dramatically increased repository size
and made audits difficult.

All such binaries have been removed from version control. Patterns have been
added to `.gitignore` so future commits do not accidentally include compiled
artifacts. Source code remains intact for reference and historical purposes.
