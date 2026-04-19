package game.ecs.components;

enum IngredientType {
	Bread;
	Meat;
	Cheese;
	Tomato;
	Lettuce;
	Onion;
	Cucumber;
}

enum IngredientState {
	Raw;
	Chopped;
	Cooked;  // fried (Pan)
	Boiled;  // boiled/stewed (Pot)
	Burnt;
	Spoiled;
}

/**
 * Debug-visible ingredient data. State/freshness fields are stored but not yet
 * driven by any system — future Phase 2 wires cooking/chopping/spoilage.
 */
class Ingredient implements Component {
	public var type(default, null):IngredientType;
	public var state:IngredientState = Raw;
	public var freshness:Float = 0;         // seconds since spawn
	public var maxFreshness:Float;          // TTL before auto-spoil
	public var processedTime:Float = 0;     // seconds accumulated on stations

	public function new(type:IngredientType, maxFreshness:Float = 120) {
		this.type = type;
		this.maxFreshness = maxFreshness;
	}
}
