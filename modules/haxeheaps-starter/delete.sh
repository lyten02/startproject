#!/usr/bin/env bash
# delete.sh — DISABLE this module (remove symlinks) and PERMANENTLY delete its directory.
# Usage: bash modules/haxeheaps-starter/delete.sh
#
# DESTRUCTIVE: removes modules/haxeheaps-starter/ entirely. No undo from this script.
# If the module has uncommitted/unpushed changes, they are lost.
# Note: haxeheaps-starter is declared in modules.json — after deletion the
# project build will fail until the module is re-fetched or modules.json is updated.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_NAME="$(basename "$SCRIPT_DIR")"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "About to PERMANENTLY delete: $SCRIPT_DIR"
echo "This also removes any symlinks in $PROJECT_ROOT/.claude/skills/ that point here."
read -r -p "Type the module name ('$MODULE_NAME') to confirm: " confirm
if [[ "$confirm" != "$MODULE_NAME" ]]; then
  echo "confirmation failed — aborted"
  exit 1
fi

if [[ -f "$SCRIPT_DIR/disable.sh" ]]; then
  bash "$SCRIPT_DIR/disable.sh" || echo "warn: disable.sh failed — continuing"
else
  echo "no disable.sh — skipping unlink step"
fi

cd "$PROJECT_ROOT"
rm -rf "$SCRIPT_DIR"
echo "removed $SCRIPT_DIR"
