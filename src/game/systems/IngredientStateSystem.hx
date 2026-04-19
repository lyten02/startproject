package game.systems;

import game.core.IngredientPalette;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Ingredient;
import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Ingredient.IngredientType;
import game.ecs.components.Hands;
import game.ecs.components.Plate;
import game.ecs.components.PlayerControlled;
import game.ecs.components.SpriteRender;
import game.ecs.components.Transform;
import game.input.GameAction;
import game.input.InputBindings;
import game.recipes.IngredientCatalog;

/**
 * Debug state control + freshness tick.
 *   - Each frame, decays `freshness` upward for every ingredient (held or not).
 *     Reaching `maxFreshness` auto-transitions to Spoiled.
 *   - If the player's facing cell contains a resting ingredient and a number
 *     key 1..5 was pressed this frame, overrides state immediately.
 *   - Mirrors state → `SpriteRender.tint` so the renderer doesn't need to know
 *     about Ingredient.
 */
class IngredientStateSystem implements ISystem {
	var input:InputBindings;

	public function new(input:InputBindings) {
		this.input = input;
	}

	public function update(world:World, dt:Float):Void {
		var req = readOverride();
		var target = req != null ? facingIngredient(world) : null;
		if (target != null && req != null) setState(target, req);

		if (input.wasPressed(GameAction.DebugToggleDirty)) {
			var p = facingOrHeldPlate(world);
			if (p != null) p.dirty = !p.dirty;
		}

		for (e in world.query(Ingredient)) {
			var ing = e.get(Ingredient);
			var car = e.get(Carryable);
			var held = car != null && car.heldBy != null;
			if (!held && ing.state != Spoiled) {
				ing.freshness += dt;
				if (ing.freshness >= ing.maxFreshness) setState(e, Spoiled);
			}
			syncSprite(e, ing.type, ing.state);
		}
	}

	static function setState(e:Entity, s:IngredientState):Void {
		var ing = e.get(Ingredient);
		ing.state = s;
		ing.processedTime = 0;
		ing.freshness     = 0; // resetting to fresh on any state transition
		syncSprite(e, ing.type, s);
	}

	static inline function syncSprite(e:Entity, type:IngredientType, state:IngredientState):Void {
		var sr = e.get(SpriteRender);
		if (sr == null) return;
		if (IngredientCatalog.hasStateSprite(type, state)) {
			sr.resPath = IngredientCatalog.iconPathFor(type, state);
			sr.tint    = 0xFFFFFF; // per-state art already encodes look; no tint
		} else {
			sr.tint = IngredientPalette.tintFor(state);
		}
	}

	function readOverride():IngredientState {
		if (input.wasPressed(GameAction.DebugStateRaw))     return Raw;
		if (input.wasPressed(GameAction.DebugStateChopped)) return Chopped;
		if (input.wasPressed(GameAction.DebugStateCooked))  return Cooked;
		if (input.wasPressed(GameAction.DebugStateBurnt))   return Burnt;
		if (input.wasPressed(GameAction.DebugStateSpoiled)) return Spoiled;
		if (input.wasPressed(GameAction.DebugStateBoiled))  return Boiled;
		return null;
	}

	static function facingOrHeldPlate(world:World):Plate {
		var players = world.query(PlayerControlled);
		if (players.length == 0) return null;
		var player = players[0];
		var hands = player.get(Hands);
		if (hands != null && hands.held != null) {
			var p = hands.held.get(Plate);
			if (p != null) return p;
		}
		var cell = InteractQueries.facingCell(player);
		for (e in world.query(Plate)) {
			var car = e.get(Carryable);
			if (car != null && car.heldBy != null) continue;
			var tr = e.get(Transform);
			var co = e.get(Collider);
			if (tr == null || co == null) continue;
			var cx = Std.int((tr.pos.x + co.w * 0.5) / game.core.Grid.CELL);
			var cy = Std.int((tr.pos.y + co.h * 0.5) / game.core.Grid.CELL);
			if (cx == cell.x && cy == cell.y) return e.get(Plate);
		}
		return null;
	}

	static function facingIngredient(world:World):Entity {
		var players = world.query(PlayerControlled);
		if (players.length == 0) return null;
		var cell = InteractQueries.facingCell(players[0]);
		for (e in world.query(Ingredient)) {
			var car = e.get(Carryable);
			if (car != null && car.heldBy != null) continue;
			var tr = e.get(Transform);
			var co = e.get(Collider);
			if (tr == null || co == null) continue;
			var cx = Std.int((tr.pos.x + co.w * 0.5) / game.core.Grid.CELL);
			var cy = Std.int((tr.pos.y + co.h * 0.5) / game.core.Grid.CELL);
			if (cx == cell.x && cy == cell.y) return e;
		}
		return null;
	}
}
