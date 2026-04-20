#!/usr/bin/env bash
# disable.sh — deactivate this module in the project.
#
# Reverse of enable.sh:
#   1. remove `modules/<name>/src` from build profile sourcePaths
#   2. unlink this module's Claude skills from .claude/skills/
#
# Does NOT delete the module directory — use delete.sh for that.
#
# Usage: bash modules/<this-module>/disable.sh

set -euo pipefail

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

# --- 1. PROFILE -------------------------------------------------------------

log "stage 1: remove from build profile"
"$PYTHON" - "$PROFILE" "$MODULE_REL/src" <<'PY'
import json, pathlib, sys
path, entry = pathlib.Path(sys.argv[1]), sys.argv[2]
if not path.exists():
    print(f"[warn] profile not found: {path}")
    sys.exit(0)
data = json.loads(path.read_text(encoding="utf-8"))
paths = data.get("sourcePaths", [])
if entry in paths:
    paths.remove(entry)
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    print(f"removed from sourcePaths: {entry}")
else:
    print(f"not registered: {entry}")
PY

# --- 2. UNLINK SKILLS -------------------------------------------------------

log "stage 2: unlink skills"
SRC="$SCRIPT_DIR/claude/skills"
DEST="$PROJECT_ROOT/.claude/skills"
removed=0
if [[ -d "$SRC" && -d "$DEST" ]]; then
  for dir in "$SRC"/*/; do
    [[ -d "$dir" ]] || continue
    name="$(basename "$dir")"
    link_path="$DEST/$name"
    if [[ -L "$link_path" ]]; then
      rm "$link_path"
      ok "unlinked skill $name"
      removed=$((removed + 1))
    elif [[ -e "$link_path" ]]; then
      warn "$link_path is not a symlink — skipping"
    fi
  done
fi
log "done ($removed skill(s) unlinked)"
