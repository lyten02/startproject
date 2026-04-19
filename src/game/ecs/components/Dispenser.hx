package game.ecs.components;

/**
 * Station that spawns Carryables on demand.
 * `ingredient` — null/"" = plate dispenser (default), else ingredient id
 * ("tomato"/"bread"/…) matching IngredientType name (case-insensitive).
 */
class Dispenser implements Component {
	public var stock:Int;
	public var ingredient:String;

	public function new(stock:Int = 0, ingredient:String = null) {
		this.stock = stock;
		this.ingredient = ingredient;
	}
}
