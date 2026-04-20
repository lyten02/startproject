# Test1234

Haxe/Heaps.io game.

## Quick start

```bash
git clone <this-repo-url>
cd <this-repo>

# Activate each module (starter first — it bootstraps infra + templates)
bash modules/haxeheaps-starter/enable.sh
bash modules/localization-base/enable.sh
bash modules/localization-text/enable.sh
bash modules/localization-audio-subtitle/enable.sh

# Build / test / run — build.py is owned by gd-builder
python modules/gd-builder/build.py build debug web
python modules/gd-builder/build.py test
python modules/gd-builder/build.py run debug web
```

## Project layout

```
src/     — game code (ECS, systems, states, UI)
res/     — assets (sprites, maps, fonts)
test/    — utest specs (pure logic, no Heaps deps)
modules/ — reusable modules (git subtrees); see modules/README.md
```

## Modules

| Module | Purpose |
|---|---|
| `gd-builder` | Build orchestrator — owns `build.py` (build/run/watch/publish/clean/test/lint) |
| `haxeheaps-starter` | Project framework: CLAUDE.md, hooks, skill-writer, `AppBase/IGame/IModule` |
| `localization-base` | i18n contracts (locale ids, events) |
| `localization-text` | Runtime text translation for Heaps |
| `localization-audio-subtitle` | Voice-line subtitles (skeleton) |

Lifecycle commands (per-module): `enable.sh`, `disable.sh`, `delete.sh`.
Full lifecycle + subtree push/pull instructions: `modules/README.md`.

## License

Private project.
