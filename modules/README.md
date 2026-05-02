# modules/ — reusable building blocks

Every directory here is a **git-subrepo** tracking an upstream GitHub repo.
Content lives in the main project's git history — one `git clone` (no
`--recursive`, no submodule init) brings everything. Per-module sync is a
single command.

> Requires `git-subrepo` installed (`brew install git-subrepo`). Without it
> the files still work — only `pull` / `push` to upstream need the tool.

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

**Delete** = disable + `rm -rf modules/<name>/`. Uncommitted/unpushed subrepo
changes are lost.

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
# Clone it into modules/ as a subrepo (from project root):
git subrepo clone https://github.com/<owner>/<repo>.git modules/<name>

# Activate via the host runner (Noreline UI → project Modules tab → Enable).
```

`git subrepo clone` creates `modules/<name>/.gitrepo` — a ~8-line metadata
file remembering the remote URL, branch, and last-synced commit. That's the
only on-disk trace of the subrepo relationship; everything else is ordinary
files.

## Updating a module from upstream

```bash
# From project root, pull the latest upstream commits:
git subrepo pull modules/<name>
```

This single command does the equivalent of fetch + merge + bookkeeping on
`.gitrepo`. No remote aliases needed — the URL is baked in on `clone`.

## Pushing your changes back to upstream

When you edit files inside `modules/<name>/` and those changes belong in the
upstream module:

```bash
git subrepo push modules/<name>
```

Subrepo slices out the subdirectory's history and pushes it to the remote.
Main-repo history stays clean (one synthetic commit per push, not merge
artifacts).

### Binding a remote later

If a module was initialised without an upstream (see TODO modules below),
attach one when its GitHub repo is ready:

```bash
# Edit modules/<name>/.gitrepo and set `remote = https://github.com/<owner>/<repo>.git`
# Then push the current state to populate the new remote:
git subrepo push modules/<name>
```

## Current modules

| Module | Upstream | Role |
|---|---|---|
| `haxeheaps-starter` | `github.com/Lyten02/haxeheaps-starter` | Project framework: `CLAUDE.md`, Claude hooks, infra templates, `skill-writer`, `AppBase/IGame/IModule` |
| `gd-builder` | `github.com/Lyten02/gd-builder` | Build orchestrator — **owns `build.py`** plus `build / run / watch / publish / clean / test / lint`. Ships `haxe/TestCollector.hx` macro. |
| `localization-base` | *(TODO — not yet on GitHub, subrepo has `remote = none`)* | Pure i18n contracts (`I18nContract`, `LocaleId`, `LocEvent`) |
| `localization-text` | *(TODO — not yet on GitHub, subrepo has `remote = none`)* | Runtime text translation for Heaps UI |
| `localization-audio-subtitle` | *(TODO — not yet on GitHub, subrepo has `remote = none`)* | Voice-line subtitles (skeleton — v1 is empty) |

Once a TODO module gets its GitHub repo, update `.gitrepo` in that directory
to set the `remote` URL, then `git subrepo push modules/<name>` to publish the
current tree.

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
- `modules/<name>/.gitrepo` — per-module subrepo metadata (auto-managed).
