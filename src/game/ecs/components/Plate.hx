package game.ecs.components;

import game.ecs.Entity;
import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Ingredient.IngredientType;

/** Snapshot of an ingredient stored inside a Plate (no live entity). */
typedef PlateSlot = {
	type:IngredientType,
	state:IngredientState,
	freshness:Float,
	maxFreshness:Float,
};

/**
 * Plate acts as a small container for up to MAX ingredient snapshots.
 * When an ingredient entity is placed onto a plate, InteractSystem destroys
 * the entity and appends a snapshot here — contents travel with the plate.
 */
class Plate implements Component {
	public static inline var MAX:Int = 10;

	public var contents:Array<PlateSlot> = [];
	public var stackedPlates:Array<Entity> = []; // plate entities resting on top
	public var dish:Null<Dish> = null; // set by PlateMergeSystem when contents match a recipe
	public var dirty:Bool     = false;
	public var washTime:Float = 0; // seconds accumulated on a Sink this cycle

	public inline function hasStack():Bool return stackedPlates.length > 0;

	public function new() {}

	public inline function isFull():Bool return contents.length >= MAX;

	public inline function add(t:IngredientType, s:IngredientState, freshness:Float = 0, maxFreshness:Float = 120):Void {
		contents.push({ type: t, state: s, freshness: freshness, maxFreshness: maxFreshness });
	}
}
