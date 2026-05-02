# StartProject — Haxe/Heaps starter with module system

> Managed by [Noreline](https://github.com/Lyten02/Noreline). Every module under
> `modules/` is self-contained: its lifecycle is described declaratively in a
> `module.json` shipped with the module. A host runner (Noreline UI) executes
> the operations cross-platform — no shell scripts, no symlink hacks.

## What's inside

- **`src/`** — project-specific Haxe code (game logic).
- **`res/`** — resources (textures, audio, locale files, maps).
- **`test/`** — utest specs for pure-logic classes.
- **`build/profiles/main.json`** — single source of truth for which module
  source directories are compiled. Updated by the host runner when modules
  are enabled / disabled.
- **`modules/`** — git submodules. Each provides:
  - `src/` — the module's Haxe code (when applicable).
  - `module.json` — declarative lifecycle metadata (links, clones,
    sourcePaths, skillsDir, dependencies).
  - Optionally: `claude/skills/`, `test/`, `CLAUDE.md`.

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

## Module lifecycle (declarative)

Each module's `module.json` declares the operations its host should perform on
**enable** (and reverse on **disable**). Schema v1:

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

Every field except `name` is optional. The host runner:

- **`links`** — symlink (or junction on Windows / fallback copy) from module
  path into the project tree.
- **`clones`** — one-shot copy with `ifMissing` semantics (never overwrites).
  Project owns the result; not removed on disable.
- **`sourcePaths`** — append to `build/profiles/main.json.sourcePaths` so the
  Haxe compiler picks up the module's source.
- **`skillsDir`** — copy each subdirectory of `<module>/<skillsDir>/` into
  `.claude/skills/<module>__<skill>/` (namespaced to avoid conflicts).

**Disable** reverses links, sourcePaths, and skills (clones stay — project
owns them). **Delete** = disable + remove the module directory entirely.

## Cloning the project

```bash
git clone --recurse-submodules https://github.com/Lyten02/StartProject.git
# Or, after a plain clone:
git submodule update --init --recursive
```

## Adding a new module

Through the Noreline UI on the project's Modules tab, or manually:

```bash
git submodule add https://github.com/owner/<name>.git modules/<name>
# Then activate via the host runner.
```

A new module just needs a `module.json` describing its lifecycle. No shell
scripts to write.

## Pulling module updates

```bash
git submodule update --remote modules/<name>
git add modules/<name>
git commit -m "chore(modules): bump <name>"
```

## Pushing module changes upstream

```bash
cd modules/<name>
git checkout main
git add . && git commit -m "..."
git push origin main
cd ../..
git add modules/<name>
git commit -m "chore(modules): bump <name>"
```
