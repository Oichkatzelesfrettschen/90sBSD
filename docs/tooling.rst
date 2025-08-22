Code Analysis Tooling
=====================

The following utilities assist in understanding the aging 386BSD codebase:

* **cloc** – identifies programming languages present in the tree.
* **clang-tidy** – parses C sources in C89 mode to flag K&R style and
  other dialect issues.
* **cppcheck** – detects common defects that contribute to technical debt.
* **clang-format** – enforces consistent C formatting.
* **bear** – generates *compile_commands.json* for large-scale analysis
  with ``clang-tidy``.

Example usage is provided by ``scripts/analyze_code.sh`` which gathers
language statistics and runs both ``cppcheck`` and ``clang-tidy`` on a
sample kernel file.
