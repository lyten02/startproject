"""PostToolUse hook: god-file guard for .hx files.

Stdin receives Claude Code hook JSON. Exits 2 (blocking feedback for
PostToolUse) when a src/**/*.hx file exceeds 200 LOC, so the model is
forced to decompose before continuing.

Non-.hx files and paths outside src/ are ignored (exit 0).
"""

from __future__ import annotations

import json
import os
import sys
from pathlib import Path

LINE_LIMIT = 200
# Hook lives inside the starter module; CLAUDE_PROJECT_DIR is set by
# Claude Code at invocation and points at the project being edited.
PROJECT_ROOT = Path(os.environ.get("CLAUDE_PROJECT_DIR", Path.cwd()))


def _extract_path(payload: dict) -> str | None:
    ti = payload.get("tool_input") or {}
    return ti.get("file_path") or (payload.get("tool_response") or {}).get("filePath")


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0  # no stdin / bad JSON — don't block

    fp = _extract_path(payload)
    if not fp:
        return 0

    p = Path(fp)
    if p.suffix.lower() != ".hx":
        return 0

    try:
        rel = p.resolve().relative_to(PROJECT_ROOT).as_posix()
    except ValueError:
        return 0
    if not rel.startswith("src/"):
        return 0

    try:
        lines = sum(1 for _ in p.open("r", encoding="utf-8", errors="replace"))
    except OSError:
        return 0

    if lines > LINE_LIMIT:
        msg = (
            f"God-file guard: {rel} is {lines} LOC (limit {LINE_LIMIT}). "
            f"Decompose into sibling files before continuing. "
            f"See CLAUDE.md 'God-file detection'."
        )
        print(msg, file=sys.stderr)
        return 2

    return 0


if __name__ == "__main__":
    sys.exit(main())
