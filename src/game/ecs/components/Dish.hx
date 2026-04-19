package game.ecs.components;

import game.ecs.components.Plate.PlateSlot;

enum DishType {
	Sandwich;
	Bruschetta;
	ClassicBurger;
	CheeseBurger;
	RoyalBurger;
	DoubleCheeseburger;
	TowerBurger;
}

/**
 * Finished dish produced by auto-merging ingredients on a plate.
 * `sourceSlots` is kept so rendering/scoring can inspect the source composition
 * (e.g. aggregate freshness) without re-deriving it from the recipe.
 */
class Dish implements Component {
	public var type(default, null):DishType;
	public var sourceSlots:Array<PlateSlot>;

	public function new(type:DishType, sourceSlots:Array<PlateSlot>) {
		this.type = type;
		this.sourceSlots = sourceSlots;
	}
}
