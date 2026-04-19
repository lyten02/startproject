# {{PROJECT_NAME}} — project-specific guide

Extends the generic rules from the root `CLAUDE.md` (symlink to
`modules/haxeheaps-starter/CLAUDE.md`).

## Architecture

Component-based ECS + separate-axis AABB + MVP UI. One directory = one concern.

```
src/game/
├── core/          pure math/primitives (Vec2, AABB, Grid)          [testable]
├── ecs/           Entity + World + Component marker
│   └── components/ Transform, Velocity, Collider, ShapeRender, PlayerControlled,
│                   SpriteRender, Ingredient, Cookable, Plate, Station, ...
├── systems/       ISystem impls: Input → Collision → IngredientState → Render [testable]
├── render/        Heaps-side helpers: ShapeFactory, SceneScaler, Camera
├── map/           JSON parser + EntityFactory + DishFactory → World           [testable]
├── recipes/       IngredientCatalog, IngredientMeta, recipe matcher            [testable]
├── states/        IGameState lifecycle (GameplayState, GameplaySystems)
├── ui/            MVP components
│   ├── mvp/       IView, IPresenter interfaces
│   ├── hud/       HudModel + HudView (Domkit) + HudPresenter
│   ├── title/     TitleModel + TitleView + TitlePresenter
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
                          IngredientStateSystem (cooking/chopping)
                                  ↓
                          SpriteRenderSystem + PlateStackRenderSystem → h2d scene
                                  ↓
                          Presenters → Models → Views.render()
```

## Coordinate convention

- `Transform.pos` = AABB top-left, in pixels.
- `ShapeFactory` / `SpriteRenderSystem` draw every shape in top-left-origin
  space. No mid-origin hacks.
- Grid cells = **32 px**. JSON coords are grid cells, multiplied by 32 on load.

## Map JSON format

`res/maps/level1.json` — grid coords (×32 px). One `player`, N obstacles, N
stations, N ingredients.

```json
{
  "width": 60, "height": 34,
  "entities": [
    { "type": "player",   "x": 6,  "y": 16 },
    { "type": "circle",   "x": 18, "y": 10, "r": 2 },
    { "type": "triangle", "x": 40, "y": 8,  "w": 4, "h": 4 },
    { "type": "station",  "x": 20, "y": 12, "station": "board" },
    { "type": "ingredient","x": 22, "y": 12, "ingredient": "tomato" }
  ]
}
```

Entity types: `player | rect | circle | triangle | diamond | hexagon | station | ingredient | dish`.

- `w/h` for rect/tri/diamond (grid cells), `r` for circle/hex (cells).
- Stations: `board | pan | pot | sink | trash`.
- Ingredients: see `res/data/ingredients.json` (`tomato`, `cheese`, `lettuce`,
  `onion`, `cucumber`, `meat`, `bread`) with states `raw | chopped | cooked |
  boiled | burnt | spoiled`.

## Project-specific rules

- **No hardcoded level data.** Obstacles/stations/ingredients go into
  `res/maps/*.json`, never into `.hx`. Adding a new shape = EntityFactory
  branch + ShapeKind + test.
- **Recipes live in `res/data/recipes.json`**, parsed through typedef in
  `src/game/recipes/`. Matching logic is pure (testable in `test/game/recipes/`).
- **Sprites** — all ingredient/station art in `res/sprites/`. File names match
  entity ids: `tomato_chopped.png`, `onion_burnt.png`, `station/board.png`, etc.

## When adding a new feature

1. Read affected files fully before editing.
2. Add/update pure logic in `core/`, `ecs/`, `map/`, `systems/`, `recipes/`.
3. Add utest spec in `test/` mirroring source layout.
4. Wire into `GameplaySystems` if it's a new System.
5. If UI-visible — update or add HUD/Debug presenter, not the view directly.
6. Run `python build.py lint && python build.py test` — both must be green.
