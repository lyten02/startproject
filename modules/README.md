# modules/ — reusable building blocks

Every directory here is a **git submodule** pinned to an upstream GitHub
repo. The parent repo stores only the path + URL (in `.gitmodules`) and a
160000-mode pointer to a specific commit; module content lives in its own
upstream history.

> Native git, no extra tooling. Clone with `git clone --recurse-submodules`,
> or run `git submodule update --init` after a plain clone. A one-time
> `git config --global submodule.recurse true` makes future `pull` /
> `checkout` recurse automatically.

## Lifecycle — declarative `module.json`

Each module ships a **`module.json`** describing its lifecycle as data, not as
shell scripts. A host runner (Noreline UI) executes the operations
cross-platform.

| Field                   | Effect on **enable** | Reversed on **disable** |
|-------------------------|----------------------|-------------------------|
| `lifecycle.links`       | Symlink (junction on Windows / fallback copy) module file into project tree. | Yes — `unlink`. |
| `lifecycle.clones`      | One-shot copy with `ifMissing: true` (never overwrites). | **No** — project owns the file after first enable. |
| `lifecycle.sourcePaths` | Append `modules/<name>/<path>` to `build/profiles/main.json.sourcePaths`. | Yes — remove from `sourcePaths`. |
| `lifecycle.skillsDir`   | Copy each subdir of `<module>/<skillsDir>/` to `.claude/skills/<module>__<skill>/`. | Yes — remove the namespaced skill dirs. |

**Delete** = disable + `git submodule deinit -f modules/<name>` +
`git rm -f modules/<name>` + `rm -rf .git/modules/<name>`. Uncommitted/
unpushed work inside the submodule is lost.

### Why declarative

- **Cross-platform out of the box.** No `MSYS=winsymlinks:nativestrict`, no
  inline-Python JSON-edit, no `realpath --relative-to`. The host runner
  handles platform quirks once, in one place.
- **Module author writes zero lifecycle code.** Just describe operations in
  JSON. The runner is a separate concern.
- **Inspectable.** A reviewer can read `module.json` and know exactly what
  enable will do, without tracing through five `.sh` files.

### Example — `localization-text/module.json`

```json
{
  "name": "localization-text",
  "version": "0.1.0",
  "description": "Runtime i18n: store, loader, signal, reactive text, fonts, config, macro validator.",
  "dependencies": ["localization-base"],
  "libs": ["heaps:git", "deepnightLibs"],
  "lifecycle": {
    "sourcePaths": ["src"],
    "skillsDir": "claude/skills"
  }
}
```

The richer `haxeheaps-starter/module.json` adds `links` (settings.json,
hooks dir) and `clones` (`.gitignore`, `public/index.html`,
`.github/copilot-instructions.md`, `README.md`).

The `gd-builder/module.json` is the simplest case — only `clones` (bootstraps
`build/profiles/main.json` and `build/test.hxml` once).

## Adding a new module

A module is just a git repository with `src/`, optionally `test/`,
`claude/skills/`, `CLAUDE.md`, and a **`module.json`** describing its
lifecycle. No `enable.sh`/`disable.sh`/`delete.sh`.

```bash
# Add it as a submodule (from project root):
git submodule add https://github.com/<owner>/<repo>.git modules/<name>

# Activate via the host runner (Noreline UI → project Modules tab → Enable).
```

`git submodule add` registers the path + URL in `.gitmodules` and stages a
160000-mode entry pointing at the upstream's current `HEAD`. The parent
commit captures *that exact SHA*; future cloners get the same pinned commit.

## Updating a module from upstream

```bash
# From project root, advance the pointer to the upstream's latest tip:
git submodule update --remote modules/<name>
git add modules/<name>
git commit -m "chore(modules): bump <name> to <new-sha-prefix>"
```

`update --remote` fetches the upstream branch (`main` by default; override
in `.gitmodules` with `branch = <name>`) and checks out its tip. Then `git
add` records the bumped pointer in the parent.

## Pushing your changes back to upstream

When you edit files inside `modules/<name>/` and those changes belong in the
upstream module:

```bash
cd modules/<name>
git checkout main             # submodules default to detached HEAD on clone
git add . && git commit -m "<module-scoped message>"
git push origin main
cd ../..
git add modules/<name>        # the parent records the bumped pointer
git commit -m "chore(modules): bump <name>"
```

Each submodule has its own working tree, index, and history — the parent
repo only tracks which commit of each submodule it's pinned to.

## Current modules

| Module | Upstream | Role |
|---|---|---|
| `haxeheaps-starter` | `github.com/Lyten02/haxeheaps-starter` | Project framework: `CLAUDE.md`, Claude hooks, infra templates, `skill-writer`, `AppBase/IGame/IModule` |
| `gd-builder` | `github.com/Lyten02/gd-builder` | Build orchestrator — **owns `build.py`** plus `build / run / watch / publish / clean / test / lint`. Ships `haxe/TestCollector.hx` macro. |
| `localization-base` | `github.com/Lyten02/localization-base` | Pure i18n contracts (`I18nContract`, `LocaleId`, `LocEvent`) |
| `localization-text` | `github.com/Lyten02/localization-text` | Runtime text translation for Heaps UI |
| `localization-audio-subtitle` | `github.com/Lyten02/localization-audio-subtitle` | Voice-line subtitles (skeleton — v1 is empty) |

The project-level `build/` directory at the repo root (not inside `modules/`)
holds the compiled `*.hxml` files and `profiles/main.json` — it is cloned
from `modules/gd-builder/templates/` by the host runner on `gd-builder`'s
enable, and owned by the project thereafter.

## Where to look next

- `CLAUDE.md` in this directory — short AI-oriented guide on the module
  conventions (load automatically when Claude works inside `modules/`).
- Each module's own `CLAUDE.md` — module-specific rules.
- Each module's `module.json` — declarative lifecycle (auth source of truth
  for what enable/disable does).
- `build/profiles/main.json` — the single source of truth for which
  module `src/` dirs are compiled.
- `.gitmodules` (repo root) — submodule registry (path + URL + optional
  `branch`), auto-managed by `git submodule add` / `mv`.
