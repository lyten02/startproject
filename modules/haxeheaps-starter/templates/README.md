# Test1234

Haxe/Heaps.io game.

## Quick start

```bash
git clone <this-repo-url>
cd <this-repo>

# Modules are managed by the host runner (Noreline UI → project page →
# Modules tab → Enable). For manual activation in a standalone clone,
# follow each module's module.json — see modules/README.md for the schema.

# Once modules are enabled, build / test / run via gd-builder:
python modules/gd-builder/build.py build debug web
python modules/gd-builder/build.py test
python modules/gd-builder/build.py run debug web
```

## Project layout

```
src/     — game code (ECS, systems, states, UI)
res/     — assets (sprites, maps, fonts)
test/    — utest specs (pure logic, no Heaps deps)
modules/ — reusable modules (git subrepos); see modules/README.md
```

## Modules

| Module | Purpose |
|---|---|
| `gd-builder` | Build orchestrator — owns `build.py` (build/run/watch/publish/clean/test/lint) |
| `haxeheaps-starter` | Project framework: CLAUDE.md, hooks, skill-writer, `AppBase/IGame/IModule` |
| `localization-base` | i18n contracts (locale ids, events) |
| `localization-text` | Runtime text translation for Heaps |
| `localization-audio-subtitle` | Voice-line subtitles (skeleton) |

Each module ships a **`module.json`** describing its lifecycle declaratively
(links, clones, sourcePaths, skillsDir). The host runner reads it and
performs activation cross-platform — no shell scripts required.

Full schema + subrepo push/pull instructions: `modules/README.md`.

## License

Private project.
