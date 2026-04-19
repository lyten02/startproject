"""Dispatch a Windows popup + sound for Stop and Notification hook events.

Reads Claude Code hook JSON from stdin (ignored if absent) and spawns the
PowerShell notifier asynchronously via subprocess.Popen — the hook never
blocks the harness. Uses built-in SystemSounds + System.Windows.Forms.MessageBox
(no third-party PowerShell modules).
"""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

PS = Path(__file__).resolve().parent / "hook_notify.ps1"


def main() -> int:
    payload = {}
    try:
        payload = json.load(sys.stdin)
    except Exception:
        pass

    event = (payload.get("hook_event_name") or "").strip()
    if event == "Stop":
        title = "Claude Code — готово"
        message = "Работа закончена. Проверь результат."
        kind = "stop"
    elif event == "Notification":
        title = "Claude Code — требует внимания"
        message = payload.get("message") or "Нужно подтверждение (plan mode / permission)."
        kind = "attend"
    else:
        title = "Claude Code"
        message = payload.get("message") or event or "Attention"
        kind = "info"

    try:
        subprocess.Popen(
            [
                "powershell", "-NoProfile", "-ExecutionPolicy", "Bypass",
                "-File", str(PS),
                "-title", title,
                "-message", message,
                "-kind", kind,
            ],
            creationflags=getattr(subprocess, "CREATE_NO_WINDOW", 0),
        )
    except Exception:
        pass
    return 0


if __name__ == "__main__":
    sys.exit(main())
