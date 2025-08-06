Codebase Segmentation
=====================

This document outlines the high-level structure of the 386BSD repository and tracks tooling steps executed so far.

Repository Layout
-----------------

* ``bin/`` – user command binaries.
* ``dev/`` – device management utilities.
* ``docs/`` – documentation sources (Sphinx, Doxygen templates).
* ``etc/`` – configuration files (symlink to ``/mnt/etc``).
* ``install`` – installation helper utility.
* ``mnt/`` – mount point containing persistent subdirectories (``etc/``, ``tmp/``, ``var/``).
* ``root/`` – root environment skeleton.
* ``sbin/`` – system administration binaries.
* ``scripts/`` – helper scripts for building and maintenance.
* ``tests/`` – test scaffolding.
* ``usr/`` – userland sources and build infrastructure.
* ``tmp`` and ``var`` – symlinks to ``/mnt/tmp`` and ``/mnt/var``.

Tooling History
---------------

* Installed `Doxygen`, `Sphinx`, `Graphviz`, `Breathe`, and the `sphinx_rtd_theme`.
* Executed ``sphinx-build`` to generate HTML documentation; the build completed with one warning about a missing ``breathe`` project mapping.

Next Steps
----------

1. Configure Doxygen and Breathe to map generated XML to Sphinx.
2. Iteratively document each subsystem (e.g., kernel, userland) with module-specific reStructuredText files.
3. Address warnings and unreadable paths reported during initial documentation runs.
