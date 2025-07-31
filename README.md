# 386bsd

386bsd - First open source BSD operating system, by [William](https://www.linkedin.com/in/williamjolitz/) and Lynne Jolitz.

[William Jolitz's 386bsd Notebook](https://386bsd.github.io/)

All release's are currently inconsistent due to media failures and composing from undated partial copies as I'm able to extract them from drives, tapes, and floppies.

Basically, working through boxes of decades old stuff/notes. 0.1/1.0 are self-compiling on small memory systems (<32MB), and virtual machines like QEMU and Virtual Box.

So the branches are idiosyncratic WRT time, and 0.1/1.0 are the most useful at the moment (2.0's got the most lapses at the moment).

After it all gets sorted out, look for ".x" branch which will deal with the "going forward" stuff (from a second box!).

William Jolitz.

## Symbolic Links

All symlinks that originally referenced absolute system paths have been rewritten
using the helper script `scripts/relativize_symlinks.py`. The script redirects
those targets into the repository's `placeholder` directory so the tree remains
self contained. Existing relative links were left untouched. To recreate the
original layout or adjust the placeholders, run:

```bash
python3 scripts/relativize_symlinks.py
```

To enumerate the links in this tree, run one of:

```bash
git ls-files -s | awk '$1 == "120000" {print $4 " -> " $3}'
find . -type l -print
```

Any external locations that must be preserved are noted in `placeholder/README.md`.
