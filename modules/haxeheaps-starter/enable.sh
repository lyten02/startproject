#!/usr/bin/env bash
# enable.sh — activate the haxeheaps-starter module in the project.
#
# Four stages:
#   1. SYMLINKS  — infra files that must stay in sync with the module.
#      (CLAUDE.md, .claude/settings.json, .claude/scripts)
#   2. CLONES    — template files copied into the project on first activation.
#      User owns them afterward; re-enable won't overwrite.
#      (.gitignore, public/index.html, .github/copilot-instructions.md, README.md)
#   3. PROFILE   — add `modules/haxeheaps-starter/src` to sourcePaths in
#      build/profiles/main.json so the compiler picks it up.
#   4. SKILLS    — symlink this module's Claude skills into .claude/skills/
#
# Usage: bash modules/haxeheaps-starter/enable.sh

set -euo pipefail
export MSYS=winsymlinks:nativestrict

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODULE_NAME="$(basename "$SCRIPT_DIR")"
MODULE_REL="modules/$MODULE_NAME"
PROFILE="$PROJECT_ROOT/build/profiles/main.json"

log()  { printf '\033[36m[%s]\033[0m %s\n' "$MODULE_NAME" "$*"; }
ok()   { printf '\033[32m[ok]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[warn]\033[0m %s\n' "$*"; }

# Portable Python (macOS ships `python3` only; MSYS/Linux may ship `python`).
PYTHON="$(command -v python3 || command -v python || true)"
[[ -n "$PYTHON" ]] || { warn "python not found in PATH"; exit 1; }

# Portable relative path (GNU `realpath --relative-to` is missing on macOS/BSD).
rel_path() {
  "$PYTHON" -c 'import os,sys; print(os.path.relpath(sys.argv[1], sys.argv[2]))' "$1" "$2"
}

# --- 1. SYMLINKS ------------------------------------------------------------

link() {
  local target_rel="$1" link_rel="$2"
  local link_abs="$PROJECT_ROOT/$link_rel"
  local target_abs="$SCRIPT_DIR/$target_rel"
  [[ -e "$target_abs" ]] || { warn "skip symlink — source missing: $target_rel"; return; }
  mkdir -p "$(dirname "$link_abs")"
  [[ -L "$link_abs" || -e "$link_abs" ]] && rm -rf "$link_abs"
  local rel_target
  rel_target=$(rel_path "$target_abs" "$(dirname "$link_abs")")
  ln -s "$rel_target" "$link_abs"
  ok "linked $link_rel -> $MODULE_REL/$target_rel"
}

log "stage 1: symlinks"
link "CLAUDE.md"             "CLAUDE.md"
link ".claude/settings.json" ".claude/settings.json"
link "claude/scripts"        ".claude/scripts"

# --- 2. CLONES (one-time copy, project owns the file afterward) -------------

clone() {
  local src_rel="$1" dst_rel="$2"
  local src_abs="$SCRIPT_DIR/$src_rel"
  local dst_abs="$PROJECT_ROOT/$dst_rel"
  [[ -e "$src_abs" ]] || { warn "skip clone — template missing: $src_rel"; return; }
  mkdir -p "$(dirname "$dst_abs")"
  if [[ -e "$dst_abs" ]]; then
    log "clone skipped (exists): $dst_rel"
  else
    cp "$src_abs" "$dst_abs"
    ok "cloned $dst_rel (you can customize it)"
  fi
}

log "stage 2: clones"
clone ".gitignore_project"                        ".gitignore"
clone "templates/public/index.html"               "public/index.html"
clone "templates/.github/copilot-instructions.md" ".github/copilot-instructions.md"
clone "templates/README.md"                       "README.md"

# --- 3. PROFILE (add sourcePath) --------------------------------------------

log "stage 3: register in build profile"
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

# --- 4. SKILLS --------------------------------------------------------------

log "stage 4: link skills"
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
