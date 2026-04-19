# Project Guidelines

## Code Style
- Use Haxe patterns already present in the repo: small focused classes, explicit interfaces, and lifecycle methods.
- Keep game logic in `src/game/` and keep framework-level abstractions in `modules/haxeheaps-starter/src/starter/`.
- Follow the existing state lifecycle contract in `src/game/states/IGameState.hx` (`enter`, `update`, `exit`) for new gameplay screens.
- Keep input action-driven via `src/game/input/GameAction.hx` and `src/game/input/InputBindings.hx` (do not hardcode key checks in states).

## Architecture
- Entry flow is `src/Main.hx` -> `src/game/Game.hx` (root container for input, state switching, and global Domkit style).
- States own their scene roots and are responsible for cleanup in `exit()`.
- UI uses Domkit (`src/game/ui/HudView.hx`) with styling in `res/ui/style.css`.
- The build system is Python-driven from root `build.py`, and writes generated HXML/build artifacts under `build/`.

## Build And Test
- Primary commands (from workspace root):
  - `python build.py build`
  - `python build.py run web`
  - `python build.py build web --release`
  - `python build.py watch web`
  - `python build.py test`
- If `python` is unavailable, use `python3`.
- Fast compile verification without producing output:
  - `haxe build/web_debug.hxml --no-output`
  - `haxe build/web_release.hxml --no-output`

## Conventions
- Keep resource references aligned with `-D resourcesPath=res` (use `res/`, not `bin/`).
- Preserve web target defines and output expectations from `build/web_debug.hxml` and `build/web_release.hxml`.
- SDF font rendering is sensitive to channel selection; follow existing usage in demo states when adding new SDF text.

## References
- Starter framework overview: `modules/haxeheaps-starter/README.md`
- Existing agent guidance and task context: `modules/haxeheaps-starter/CLAUDE.md`
- Platform/build caveats (HashLink/ARM, native notes): `modules/haxeheaps-starter/tools/BUILD.md`
- Store media tooling docs: `modules/haxeheaps-starter/tools/store-media/README.md`
