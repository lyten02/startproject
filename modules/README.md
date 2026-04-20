# modules/ — reusable building blocks

Every directory here is a **git-subrepo** tracking an upstream GitHub repo.
Content lives in the main project's git history — one `git clone` (no
`--recursive`, no submodule init) brings everything. Per-module sync is a
single command.

> Requires `git-subrepo` installed (`brew install git-subrepo`). Without it
> the files still work — only `pull` / `push` to upstream need the tool.

## Lifecycle — what each script does

Each module exposes three shell scripts with uniform semantics:

| Script        | Effect |
|---------------|--------|
| **enable.sh** | Activate the module. Registers `modules/<name>/src` in `build/profiles/main.json` (so the compiler picks it up), symlinks the module's Claude skills into `.claude/skills/`. For `haxeheaps-starter` it also symlinks infra (`CLAUDE.md`, `.claude/settings.json`, `.claude/scripts`) and **clones** one-shot templates (`.gitignore`, `public/index.html`, `.github/copilot-instructions.md`, `README.md`). |
| **disable.sh** | Reverse of enable. Removes the sourcePath entry from `main.json`, unlinks the module's skills. Does **NOT** delete cloned files — those are project-owned after the first enable. Does **NOT** remove the module directory. |
| **delete.sh** | DESTRUCTIVE. Runs `disable.sh` and then `rm -rf` on the module directory. Prompts for the module name as confirmation. Uncommitted/unpushed changes in the subrepo are lost. |

### Typical usage

```bash
# First-time bootstrap after `git clone`:
bash modules/gd-builder/enable.sh              # creates build/ (profiles/main.json + test.hxml)
bash modules/haxeheaps-starter/enable.sh       # infra + skills
bash modules/localization-base/enable.sh       # i18n contracts
bash modules/localization-text/enable.sh       # i18n runtime
bash modules/localization-audio-subtitle/enable.sh   # voice-line subtitles

# Temporarily disable a module (keep directory, skip it in the build):
bash modules/localization-audio-subtitle/disable.sh

# Remove permanently (after confirming with module name):
bash modules/localization-audio-subtitle/delete.sh
```

## Adding a new module

A module is just a git repository with `src/`, optionally `test/`, `claude/skills/`,
`module.json`, and the three `enable/disable/delete` scripts.

```bash
# Clone it into modules/ as a subrepo (from project root):
git subrepo clone https://github.com/<owner>/<repo>.git modules/<name>

# Activate:
bash modules/<name>/enable.sh
```

`git subrepo clone` creates `modules/<name>/.gitrepo` — a ~8-line metadata file
remembering the remote URL, branch, and last-synced commit. That's the only
on-disk trace of the subrepo relationship; everything else is ordinary files.

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

The project-level `build/` directory at the repo root (not inside `modules/`) holds
the compiled `*.hxml` files and `profiles/main.json` — it is cloned from
`modules/gd-builder/templates/` by `gd-builder/enable.sh` and owned by the project
thereafter.

## Where to look next

- `CLAUDE.md` in this directory — short AI-oriented guide on the module
  conventions (load automatically when Claude works inside `modules/`).
- Each module's own `CLAUDE.md` — module-specific rules.
- `build/profiles/main.json` — the single source of truth for which
  module `src/` dirs are compiled.
- `modules/<name>/.gitrepo` — per-module subrepo metadata (auto-managed).
