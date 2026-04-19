# modules/ — conventions (AI guide)

> Human-facing docs: see `modules/README.md`.
> Full lifecycle/push/pull commands: `modules/README.md`.

## TL;DR

Each `modules/<name>/` directory is a **git subtree** that ships `src/`,
optionally `test/`, `claude/skills/`, `module.json`, and three lifecycle
scripts: `enable.sh`, `disable.sh`, `delete.sh`.

## Lifecycle semantics

- **`enable.sh`** — activate the module.
  1. Adds `modules/<name>/src` to `build/profiles/main.json`
     (`sourcePaths`) so the compiler sees it.
  2. Symlinks the module's Claude skills into `.claude/skills/`.
  3. `haxeheaps-starter/enable.sh` additionally:
     - Symlinks infra (`CLAUDE.md`, `.claude/settings.json`, `.claude/scripts`)
       into the project.
     - **Clones** one-shot templates (`.gitignore`, `public/index.html`,
       `.github/copilot-instructions.md`, `README.md`) using `cp -n` so an
       existing project file is never overwritten.

- **`disable.sh`** — reverse of enable.
  - Removes the `sourcePaths` entry from `main.json`.
  - Unlinks the module's skills.
  - **Does NOT** remove cloned files (project owns them).
  - **Does NOT** delete the module directory.

- **`delete.sh`** — destructive.
  - Runs `disable.sh`, then `rm -rf modules/<name>/`.
  - Prompts for the module name as confirmation.
  - Uncommitted/unpushed subtree changes are lost.

## Where things live (don't confuse)

| Path | Purpose |
|---|---|
| `modules/<name>/src/` | Haxe source of the module. Compiled via `sourcePaths` in `main.json`. |
| `modules/<name>/test/` | utest specs of the module (pure logic). Scanned by `python modules/gd-builder/build.py test`. |
| `modules/<name>/claude/skills/<skill>/` | Skill directories symlinked by `enable.sh` into `.claude/skills/`. Each has `SKILL.md` with frontmatter. |
| `modules/<name>/module.json` | Metadata (author, version, optional deps). |
| `modules/<name>/CLAUDE.md` | Module-specific AI guidance — what belongs here, what does NOT. |
| `modules/gd-builder/scripts/` | Build-tool scripts (`lint.py`, `lint_rules.py`) — used by `build.py`, not by Claude directly. |
| `modules/gd-builder/haxe/` | Haxe macros owned by the build system (`TestCollector.hx`). Added to `test.hxml` via `-cp modules/gd-builder/haxe`. |
| `modules/haxeheaps-starter/claude/scripts/` | Claude Code hooks (`hook_*.py`, `hook_*.ps1`) — referenced by `.claude/settings.json`. |
| `modules/haxeheaps-starter/templates/` | Clone sources (one-shot copies into the project). |
| `build/profiles/main.json` | Source of truth for which module `src/` dirs are compiled. Auto-derived hxml files in `build/*.hxml`. |

## Rules when working inside `modules/`

1. **Don't bypass the lifecycle scripts.** Adding a module means:
   `git subtree add --prefix=modules/<name> <url> main --squash` + `enable.sh`.
   Direct manual edits to `main.json` are acceptable only as a last-resort
   override — `enable.sh` is idempotent and safe to re-run.

2. **Module edits are upstreamable.** If you change a file inside
   `modules/<name>/`, assume it will eventually be `git subtree push`'d to the
   module's upstream repo. Don't put project-specific hacks there — those go
   under `src/` of the main project.

3. **Skills and hooks live inside the owning module**, not in the project root.
   `haxeheaps-starter` owns the generic hooks + skills; a feature module owns
   its feature-specific skills.

4. **Claude-hook paths use `$CLAUDE_PROJECT_DIR`.** Never rely on
   `__file__`-traversal in a hook script — the hook file is inside the module
   but `$CLAUDE_PROJECT_DIR` is the project being linted.

5. **`setup.sh` does not exist.** The project is bootstrapped by calling
   `enable.sh` of each module in turn (starting with `haxeheaps-starter`).

## Module-adding checklist

When you create a new module:

- [ ] `module.json` with name, version, description, optional deps.
- [ ] `CLAUDE.md` — what belongs here, what doesn't (see existing loc modules
      for examples).
- [ ] `enable.sh` + `disable.sh` (copy the pattern from `localization-base/`).
- [ ] `delete.sh` (copy from `localization-base/`; no changes needed — it
      reads `basename $SCRIPT_DIR` for the module name).
- [ ] `src/` with the module's Haxe code (kept under the module's root package).
- [ ] `test/` with utest specs (if the module has pure-logic tests).
- [ ] `claude/skills/<skill-name>/SKILL.md` if the module ships a Claude skill.
- [ ] Push to upstream via
      `git subtree push --prefix=modules/<name> <url> main`.
