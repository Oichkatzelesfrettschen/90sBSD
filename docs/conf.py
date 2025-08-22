"""Sphinx configuration for the 386BSD project documentation."""
from __future__ import annotations
import os

project = "386BSD"
extensions = ["breathe", "myst_parser"]

# Breathe ties the Doxygen XML into Sphinx. The actual XML path is
# supplied by CMake at build time via -Dbreathe_projects.386bsd.
breathe_default_project = "386bsd"

html_theme = "sphinx_rtd_theme"
