# modules/ — conventions (AI guide)

> Human-facing docs: see `modules/README.md`.
> Schema reference + host-runner contract: `modules/README.md`.

## TL;DR

Each `modules/<name>/` directory is a **git submodule** that ships `src/`,
optionally `test/`, `claude/skills/`, `CLAUDE.md`, and a **`module.json`**
declaring its lifecycle as data. The parent repo pins each module to a
specific upstream commit via `.gitmodules` + a 160000-mode index entry.

The lifecycle is **declarative** — no shell scripts. A host runner (Noreline
UI on the project's Modules tab) reads `module.json` and executes the
operations cross-platform.

## Lifecycle semantics (executed by the host)

`module.json` schema v1:

```json
{
  "name": "<module-name>",
  "version": "0.1.0",
  "description": "...",
  "dependencies": ["<other-module-name>"],
  "lifecycle": {
    "links":   [ { "from": "<module-rel>", "to": "<project-rel>" } ],
    "clones":  [ { "from": "<module-rel>", "to": "<project-rel>", "ifMissing": true } ],
    "sourcePaths": ["src"],
    "skillsDir": "claude/skills"
  }
}
```

- **`links`** — symlink module file/dir into the project tree. On Windows
  the runner uses junctions for dirs. Falls back to recursive copy on
  filesystems without symlink support. Reversed on disable (`unlink`).
- **`clones`** — one-shot copy with `ifMissing: true` (never overwrites).
  Project owns the file afterward — **NOT** removed on disable.
- **`sourcePaths`** — append `modules/<name>/<path>` to
  `build/profiles/main.json.sourcePaths` so the Haxe compiler picks it up.
  Reversed on disable.
- **`skillsDir`** — copy each subdir of `<module>/<skillsDir>/` into
  `.claude/skills/<module>__<skill>/` (namespaced). Reversed on disable.

**Disable** = reverse links + sourcePaths + skills (clones stay).
**Delete** = disable + `rm -rf modules/<name>/`.

## Status detection

A module is reported **enabled** when:
- All `lifecycle.sourcePaths` are present in `build/profiles/main.json.sourcePaths`, OR
- (`sourcePaths` not declared) namespaced skill dirs `<module>__*` exist in
  `.claude/skills/`.

A module without `sourcePaths` *and* without `skillsDir` (e.g.
`gd-builder` — only clones) is a special case the runner handles by checking
clone-target existence. The schema itself does not declare an `alwaysEnabled`
flag.

## Where things live (don't confuse)

| Path | Purpose |
|---|---|
| `modules/<name>/src/` | Haxe source of the module. Compiled via `sourcePaths` in `main.json`. |
| `modules/<name>/test/` | utest specs of the module (pure logic). Scanned by `python modules/gd-builder/build.py test`. |
| `modules/<name>/claude/skills/<skill>/` | Skill directories namespace-copied by the host runner into `.claude/skills/<module>__<skill>/`. Each has `SKILL.md` with frontmatter. |
| `modules/<name>/module.json` | **Declarative lifecycle** + metadata (name, version, description, dependencies, optional `libs`). |
| `modules/<name>/CLAUDE.md` | Module-specific AI guidance — what belongs here, what does NOT. |
| `modules/gd-builder/scripts/` | Build-tool scripts (`lint.py`, `lint_rules.py`) — used by `build.py`, not by Claude directly. |
| `modules/gd-builder/haxe/` | Haxe macros owned by the build system (`TestCollector.hx`). Added to `test.hxml` via `-cp modules/gd-builder/haxe`. |
| `modules/haxeheaps-starter/claude/scripts/` | Claude Code hooks (`hook_*.py`, `hook_*.ps1`) — referenced by `.claude/settings.json`. |
| `modules/haxeheaps-starter/templates/` | Clone sources (one-shot copies into the project). |
| `build/profiles/main.json` | Source of truth for which module `src/` dirs are compiled. Auto-derived hxml files in `build/*.hxml`. |

## Rules when working inside `modules/`

1. **Don't bypass the lifecycle declaration.** If a module needs a new
   activation step, add it to `module.json.lifecycle` — never side-effect
   files at module-import time. Direct manual edits to `main.json` are
   acceptable only as a last-resort override.

2. **Module edits are upstreamable.** If you change a file inside
   `modules/<name>/`, commit it inside the submodule (`cd modules/<name> &&
   git add . && git commit && git push origin main`), then bump the parent
   pointer (`git add modules/<name>` from the project root). Don't put
   project-specific hacks there — those go under `src/` of the main project.

3. **Skills and hooks live inside the owning module**, not in the project
   root. `haxeheaps-starter` owns the generic hooks + skills; a feature
   module owns its feature-specific skills.

4. **Claude-hook paths use `$CLAUDE_PROJECT_DIR`.** Never rely on
   `__file__`-traversal in a hook script — the hook file is inside the module
   but `$CLAUDE_PROJECT_DIR` is the project being linted.

## Module-adding checklist

When you create a new module:

- [ ] `module.json` declaring `name`, `version`, `description`, optional
      `dependencies`, and the `lifecycle` block describing what enable
      should do.
- [ ] `CLAUDE.md` — what belongs here, what doesn't (see existing loc modules
      for examples).
- [ ] `src/` with the module's Haxe code (kept under the module's root
      package). Reference it via `lifecycle.sourcePaths: ["src"]`.
- [ ] `test/` with utest specs (if the module has pure-logic tests).
- [ ] `claude/skills/<skill-name>/SKILL.md` if the module ships a Claude
      skill. Reference the parent dir via `lifecycle.skillsDir: "claude/skills"`.
- [ ] Push module changes upstream from inside the submodule
      (`cd modules/<name> && git push origin main`), then commit the
      pointer bump in the parent repo (`git add modules/<name>`).

**Do NOT add `enable.sh` / `disable.sh` / `delete.sh`.** All lifecycle is in
`module.json`. The host runner is the only thing that performs activation.
