# Haxe/Heaps project — generic rules

**Role:** Game developer
**Stack:** Haxe + Heaps.io + Domkit + deepnightLibs
**Language:** First Russian, Second English

> Project-specific details (entity types, level format, ECS components, etc.)
> live in `src/CLAUDE.md` — Claude Code picks it up automatically.

## Commands

`build.py` lives in the **gd-builder** module (no project-root symlink). Invoke
via full module path. Below and in the rest of this doc, **`build.py` is shorthand
for `modules/gd-builder/build.py`** — set a shell alias if you want.

```bash
python modules/gd-builder/build.py build debug/release web   # compile web (debug or release)
python modules/gd-builder/build.py test              # run utest suite
python modules/gd-builder/build.py coverage          # c8 V8-coverage → logs/coverage/index.html
python modules/gd-builder/build.py lint              # rules A–H + god-file check
python modules/gd-builder/build.py run debug/release web           # launch in browser (debug or release)
python modules/gd-builder/build.py watch debug/release web         # live reload (debug or release)
haxe build/web_debug.hxml --no-output               # fast type check only
```

## Architecture patterns

- **ECS for gameplay.** Entities are ids, Components are data, Systems are
  logic (`ISystem`). Keep systems pure and testable.
- **MVP for UI.**
  - **Model** = plain data (public fields), no logic.
  - **View** = Domkit `@:uiComp` implementing `IView<TModel>`; renders only.
  - **Presenter** = reads World/game state, populates Model, calls
    `view.render(m)`.
  - View never reads the World. Presenter never calls Heaps draw APIs.
- **One directory = one concern.** Core math in `core/`, ECS components in
  `ecs/components/`, systems in `systems/`, UI in `ui/*/`.
- **JSON-driven data.** Level/config data lives in `res/**/*.json`, parsed
  through a `typedef` — never as bare `Dynamic`.

## Rules

1. **No god files.** Any `.hx` > 200 LOC needs decomposition. Before committing,
   confirm no file exceeds the limit. Check with `python build.py lint` or
   `tokei src/ --sort lines`.
2. **One class per file.** Filename == class name. Sub-concerns live in
   siblings, not as inner classes in a mega-file.
3. **MVP for UI, ECS for gameplay.** Never leak game logic into a View or a
   rendering call into a Presenter. Never put game state on a Heaps object
   (`sprite.hp = 100` is forbidden).
4. **No hardcoded level/config data.** Maps, ingredients, recipes, etc. live
   in `res/**/*.json`, never in `.hx` code.
5. **Tests.** Every class in `core/`, `ecs/`, `map/`, `systems/` has a spec in
   `test/`. Pure logic only — no Heaps deps in tests.
   `python build.py test` must stay green.
6. **Input is action-driven.** Never `hxd.Key.*` in game code — go through
   `GameAction` + `InputBindings.moveX/moveY/isDown/wasPressed`.
7. **SDF font channel = `Alpha`** for `*_sdf`. Atlas has only ASCII Latin.
8. **Always lint before handing back.** `python build.py lint` — runs type-check
   and god-file detection. Must exit 0 before any commit.

## Memory protocol

- **Read source before editing.** Don't hallucinate Heaps API — check
  `C:/HaxeToolkit/haxe/lib/heaps/2,1,0/` when unsure.
- **Check dependencies.** Use only libs in
  `build/profiles/main.json` (`heaps:git`, `domkit`,
  `deepnightLibs`, `utest` for tests).
- **User runs QA.** Finish a task by describing reproducible steps
  (`do A then B → expect C`), not by claiming it "works".

## Anti-hallucination checklist (enforced by `lint`)

Lint rejects these patterns (`python build.py lint`, rules A–H):

- **A** `h3d.scene|prim|mat|anim|shader|pass` in `src/` — project is 2D (h2d).
  `h3d.Engine.*` is allowed (bootstrap).
- **B** `import unity. / three. / browser. / js.html. / react / vue` —
  foreign ecosystems.
- **C** `MonoBehaviour`, `[SerializeField]`, `@:serialize` — Unity/C# ports.
- **D** `import h2d|hxd|h3d` in `test/` — tests are pure logic.
- **E** identifier `World` in `ui/**/*View.hx` — View doesn't read World.
- **F** `import h2d|hxd` in `ui/**/*Presenter.hx` — Presenter doesn't draw.
- **G** `@:uiComp` without `static var SRC` — Domkit requires a template.
- **H** `hxd.Key.` in `src/game/` (except `input/`) — only `GameAction` +
  `InputBindings`.

Self-checks before commit:
- ECS component = `implements Component`, not `extends MonoBehaviour`.
- Game state lives in ECS components. Never on `h2d.Object`.
- JSON read through `typedef`, not raw `Dynamic`.
- View receives data through `render(model)`; doesn't read the world itself.
- Build/tests — only `python build.py *`, not `npm` / `cmake`.

## God-file detection

Zero-dependency check — run before every commit:

```bash
# Worst offenders (bash / git-bash / WSL):
find src test -name "*.hx" -exec wc -l {} + | sort -rn | head -15

# Or from PowerShell:
Get-ChildItem src,test -Recurse -Filter *.hx | Select-Object FullName,
    @{n='Lines';e={(Get-Content $_.FullName).Count}} | Sort-Object Lines -Desc
```

Any `.hx` file exceeding **200 LOC** must be decomposed — extract sub-classes
into sibling files under the same package directory.

For deeper metrics (cyclomatic complexity, Halstead, MI), install
[`rust-code-analysis-cli`](https://crates.io/crates/rust-code-analysis-cli)
via `cargo install rust-code-analysis-cli` — then
`rust-code-analysis-cli -p src/ -m` flags high-CC files.

This CLAUDE.md itself is capped at 200 lines — check `wc -l CLAUDE.md` after
edits.
