#!/usr/bin/env bash
# enable.sh — activate this module in the project.
#
# Two stages:
#   1. PROFILE — add `modules/<name>/src` to sourcePaths in
#      build/profiles/main.json so the compiler picks it up.
#   2. SKILLS  — symlink this module's Claude skills into .claude/skills/
#
# Usage: bash modules/<this-module>/enable.sh

set -euo pipefail
export MSYS=winsymlinks:nativestrict

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODULE_NAME="$(basename "$SCRIPT_DIR")"
MODULE_REL="modules/$MODULE_NAME"
PROFILE="$PROJECT_ROOT/build/profiles/main.json"

log() { printf '\033[36m[%s]\033[0m %s\n' "$MODULE_NAME" "$*"; }
ok()  { printf '\033[32m[ok]\033[0m %s\n' "$*"; }

# Portable Python (macOS ships `python3` only; MSYS/Linux may ship `python`).
PYTHON="$(command -v python3 || command -v python || true)"
[[ -n "$PYTHON" ]] || { echo "[error] python not found in PATH"; exit 1; }

# Portable relative path (GNU `realpath --relative-to` is missing on macOS/BSD).
rel_path() {
  "$PYTHON" -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$1" "$2"
}

# --- 1. PROFILE -------------------------------------------------------------

log "stage 1: register in build profile"
"$PYTHON" - "$PROFILE" "$MODULE_REL/src" <<'PY'
import json, pathlib, sys
path, entry = pathlib.Path(sys.argv[1]), sys.argv[2]
if not path.exists():
    print(f"[warn] profile not found: {path}")
    sys.exit(0)
data = json.loads(path.read_text(encoding="utf-8"))
paths = data.setdefault("sourcePaths", [])
if entry in paths:
    print(f"already registered: {entry}")
else:
    paths.append(entry)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"added to sourcePaths: {entry}")
PY

# --- 2. SKILLS --------------------------------------------------------------

log "stage 2: link skills"
SRC="$SCRIPT_DIR/claude/skills"
DEST="$PROJECT_ROOT/.claude/skills"
mkdir -p "$DEST"
linked=0
if [[ -d "$SRC" ]]; then
  for dir in "$SRC"/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"
    link_path="$DEST/$name"
    [[ -L "$link_path" || -e "$link_path" ]] && rm -rf "$link_path"
    rel_target=$(rel_path "$dir" "$DEST")
    ln -s "$rel_target" "$link_path"
    ok "linked skill $name"
    linked=$((linked + 1))
  done
fi
log "done ($linked skill(s) linked into .claude/skills/)"
