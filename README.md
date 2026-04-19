# StartProject — Haxe/Heaps starter with module system

> Managed by [GD-Site](https://github.com/Lyten02/GD-Site). Every module under
> `modules/` is self-contained: its lifecycle is controlled by three scripts
> shipped with the module itself — `enable.sh`, `disable.sh`, `delete.sh`.

## What's inside

- **`src/`** — project-specific Haxe code (game logic).
- **`res/`** — resources (textures, audio, locale files, maps).
- **`test/`** — utest specs for pure-logic classes.
- **`build/profiles/main.json`** — single source of truth for which module
  source directories are compiled (updated by `enable.sh` / `disable.sh`).
- **`modules/`** — git subtree'd modules. Each provides:
  - `src/` — the module's Haxe code.
  - `enable.sh`, `disable.sh`, `delete.sh` — lifecycle scripts.
  - Optionally: `claude/skills/`, `test/`, `CLAUDE.md`.
- **`modules/status.md`** — per-project record of which modules are enabled /
  disabled. Written by GD-Site when the project is created and updated when
  you toggle modules in the UI.

## Shipped modules

- **`gd-builder`** — build tooling (`python modules/gd-builder/build.py …`).
- **`haxeheaps-starter`** — Heaps-side infrastructure + generic Claude hooks.
- **`localization-base`** — pure i18n contracts (zero deps).
- **`localization-text`** — runtime text i18n for Heaps.
- **`localization-audio-subtitle`** — audio + subtitle i18n.

## Build commands

```bash
python modules/gd-builder/build.py build debug web
python modules/gd-builder/build.py test
python modules/gd-builder/build.py lint
python modules/gd-builder/build.py run debug web
python modules/gd-builder/build.py watch debug web
```

## Adding a new module (from GD-Site UI)

Click the project title (the `🎮 ProjectName` header on the project page),
then paste a module repo URL and press **Add**. GD-Site runs
`git subtree add --prefix=modules/<name> <url> <branch> --squash`,
executes the module's `enable.sh`, and updates `modules/status.md`.

## Adding a new module (manually)

```bash
git subtree add --prefix=modules/<name> https://github.com/owner/<name>.git main --squash
bash modules/<name>/enable.sh
```

## Pushing module changes upstream

```bash
git subtree push --prefix=modules/<name> https://github.com/owner/<name>.git main
```

## Pulling module updates

```bash
git subtree pull --prefix=modules/<name> https://github.com/owner/<name>.git main --squash
```
