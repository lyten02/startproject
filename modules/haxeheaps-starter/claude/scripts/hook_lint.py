"""Async PostToolUse hook: run `python build.py lint` when a .hx file changes.

Runs in the background (hook declared with async:true). Stdout/stderr are not
shown to the model; errors land in the harness log. Skips work when the edit
wasn't a .hx file so we don't re-lint on every random edit.
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
from pathlib import Path

# Claude Code sets CLAUDE_PROJECT_DIR when invoking hooks. The hook script
# itself lives inside the starter module, so resolving __file__ would point
# at the module — not the project being linted.
PROJECT_ROOT = Path(os.environ.get("CLAUDE_PROJECT_DIR", Path.cwd()))
BUILD_PY = PROJECT_ROOT / "modules" / "gd-builder" / "build.py"


def main() -> int:
    try:
        payload = json.load(sys.stdin)
    except Exception:
        return 0

    ti = payload.get("tool_input") or {}
    fp = ti.get("file_path") or (payload.get("tool_response") or {}).get("filePath")
    if not fp or not fp.lower().endswith(".hx"):
        return 0

    try:
        subprocess.run(
            ["python", str(BUILD_PY), "lint"],
            cwd=str(PROJECT_ROOT),
            timeout=120,
            check=False,
        )
    except Exception:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
