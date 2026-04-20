# Test1234 — project-specific guide

Extends the generic rules from the root `CLAUDE.md` (symlink to
`modules/haxeheaps-starter/CLAUDE.md`).

## Architecture

Component-based ECS + separate-axis AABB + MVP UI. One directory = one concern.

```
src/game/
├── core/          pure math/primitives (Vec2, AABB, Grid, TimeScale)  [testable]
├── ecs/           Entity + World + Component marker
│   └── components/ Transform, Velocity, Collider, ShapeRender,
│                   SpriteRender, PlayerControlled
├── systems/       ISystem impls: Input → Collision → Render           [testable]
├── render/        Heaps-side helpers: ShapeFactory, SceneScaler, Camera
├── map/           JSON parser + EntityFactory → World                  [testable]
├── states/        IGameState lifecycle (GameplayState, GameplaySystems)
├── ui/            MVP components
│   ├── mvp/       IView, IPresenter interfaces
│   ├── orient/    OrientModel + OrientView + OrientPresenter
│   └── debug/     DebugModel + DebugView + DebugPresenter
├── input/         GameAction enum + InputBindings (deepnightLibs)
└── Game.hx        IGame root — owns input/style/state/orient overlay
```

## Data flow (per frame)

```
InputBindings → InputSystem → Velocity
                                  ↓
                          CollisionSystem (AABB slide)
                                  ↓
                          RenderSystem + SpriteRenderSystem → h2d scene
                                  ↓
                          Presenters → Models → Views.render()
```

## Coordinate convention

- `Transform.pos` = AABB top-left, in pixels.
- `ShapeFactory` / `SpriteRenderSystem` draw every shape in top-left-origin
  space. No mid-origin hacks.
- Grid cells = **32 px**. JSON coords are grid cells, multiplied by 32 on load.

## Map JSON format

`res/maps/level1.json` — grid coords (×32 px). One `player`, N obstacles.

```json
{
  "width": 60, "height": 34,
  "entities": [
    { "type": "player",   "x": 4,  "y": 16 },
    { "type": "rect",     "x": 10, "y": 10, "w": 4, "h": 2 },
    { "type": "circle",   "x": 20, "y": 12, "r": 2 },
    { "type": "triangle", "x": 30, "y": 8,  "w": 3, "h": 3 },
    { "type": "diamond",  "x": 40, "y": 15, "w": 3, "h": 3 },
    { "type": "hexagon",  "x": 50, "y": 10, "r": 2 }
  ]
}
```

Entity types: `player | rect | circle | triangle | diamond | hexagon`.

- `w/h` for rect/tri/diamond (grid cells), `r` for circle/hex (cells).

## Project-specific rules

- **No hardcoded level data.** Obstacles go into `res/maps/*.json`, never into `.hx`.
  Adding a new shape = EntityFactory branch + ShapeKind + test.

## When adding a new feature

1. Read affected files fully before editing.
2. Add/update pure logic in `core/`, `ecs/`, `map/`, `systems/`.
3. Add utest spec in `test/` mirroring source layout.
4. Wire into `GameplaySystems` if it's a new System.
5. If UI-visible — update or add Debug presenter, not the view directly.
6. Run `python build.py lint && python build.py test` — both must be green.
