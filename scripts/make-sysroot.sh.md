# make-sysroot.sh

The following shell script assembles a 386BSD cross-compilation sysroot.

```bash
#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# make-sysroot.sh -- construct a Clang-friendly 386BSD sysroot
# ---------------------------------------------------------------------------
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.."; pwd)"
SYSROOT="${SYSROOT:-$ROOT/sysroots/386bsd-elf}"

HDR_SRC=(
  "$ROOT/usr/include"
  "$ROOT/usr/src/include"
  "$ROOT/usr/src/lib/libc/include"
)
LIBC_DIR="$ROOT/usr/src/lib/libc"

echo "[*] Creating sysroot at: $SYSROOT"
mkdir -p "$SYSROOT/usr/include" "$SYSROOT/usr/lib"

found=0
for d in "${HDR_SRC[@]}"; do
  if [ -d "$d" ]; then
    echo "[*] Installing headers from $d"
    rsync -a --delete --exclude 'nonstd/**' "$d"/ "$SYSROOT/usr/include"/ || true
    found=1
  fi
done
if [ "$found" -eq 0 ]; then
  echo "!! Could not locate 386BSD headers. Check paths in make-sysroot.sh" >&2
  exit 1
fi

for hdr in sys/cdefs.h machine/ansi.h; do
  if [ ! -f "$SYSROOT/usr/include/$hdr" ]; then
    echo "!! Missing $hdr in sysroot" >&2
    exit 1
  fi
done

if [ -f "$ROOT/scripts/relativize_symlinks.py" ]; then
  (cd "$ROOT" && python3 scripts/relativize_symlinks.py)
fi

export CC=clang
export AR=llvm-ar
export RANLIB=llvm-ranlib
export SYSROOT

CFLAGS="-ffreestanding -fno-builtin -m32 -march=i386 -mno-sse -mno-sse2 -mno-mmx -msoft-float \
        -nostdinc -isystem $SYSROOT/usr/include -O2 -fno-omit-frame-pointer -fno-stack-protector"
LDFLAGS="-static --sysroot=$SYSROOT -m elf_i386 -nostdlib"

WORK="$(mktemp -d "$ROOT/.libc-build.XXXXXX")"
trap 'rm -rf "$WORK"' EXIT
find "$LIBC_DIR" -type f -name '*.c' > "$WORK/files.lst" || true

if [ ! -s "$WORK/files.lst" ]; then
  echo "!! No libc sources found at $LIBC_DIR; adjust make-sysroot.sh" >&2
  exit 1
fi

while IFS= read -r f; do
  out="$WORK/$(echo "$f" | sed 's/[^A-Za-z0-9_]/_/g').o"
  echo "  CC $f"
  "$CC" --target=i386-unknown-elf $CFLAGS -c "$f" -o "$out" || {
    echo "!! Failed compiling $f"; exit 1; }
done < "$WORK/files.lst"

echo "[*] Archiving libc.a"
"$AR" rcs "$SYSROOT/usr/lib/libc.a" "$WORK"/*.o
"$RANLIB" "$SYSROOT/usr/lib/libc.a"

echo "[✓] Sysroot ready: $SYSROOT"
```
