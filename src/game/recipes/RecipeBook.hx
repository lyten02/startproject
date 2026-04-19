package game.recipes;

import game.ecs.components.Dish.DishType;
import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Ingredient.IngredientType;
import game.recipes.Recipe;

/**
 * Recipe registry. Default contents mirror res/data/recipes.json so unit tests
 * work without JSON I/O; GameplayState overrides `ALL` and `META` at runtime
 * via `load()` after parsing the JSON files.
 *
 * Matcher iterates `ALL` sorted by length DESC then specificity DESC, so
 * more-constrained recipes win over looser ones of the same length.
 */
class RecipeBook {
	public static var ALL:Array<Recipe> = defaultRecipes();
	public static var META:Map<DishType, RecipeMeta> = new Map();

	public static function load(recipes:Array<Recipe>, meta:Map<DishType, RecipeMeta>):Void {
		ALL  = recipes;
		META = meta;
	}

	public static inline function findMeta(id:DishType):Null<RecipeMeta> return META.get(id);

	public static function findById(id:DishType):Null<Recipe> {
		for (r in ALL) if (r.id == id) return r;
		return null;
	}

	static function defaultRecipes():Array<Recipe> {
		return [
			{ id: Sandwich,           ordered: false, items: [ {type: Bread}, {type: Cheese} ] },
			{ id: Bruschetta,         ordered: false, items: [ {type: Bread}, {type: Tomato, state: Chopped} ] },
			{ id: ClassicBurger,      ordered: true,  items: [
				{type: Bread}, {type: Meat, state: Cooked}, {type: Lettuce}, {type: Bread},
			] },
			{ id: CheeseBurger,       ordered: true,  items: [
				{type: Bread}, {type: Meat, state: Cooked}, {type: Cheese}, {type: Bread},
			] },
			{ id: RoyalBurger,        ordered: true,  items: [
				{type: Bread}, {type: Meat, state: Cooked}, {type: Cheese},
				{type: Tomato, state: Chopped}, {type: Lettuce}, {type: Bread},
			] },
			{ id: DoubleCheeseburger, ordered: true,  items: [
				{type: Bread}, {type: Meat, state: Cooked}, {type: Cheese},
				{type: Meat, state: Cooked}, {type: Cheese}, {type: Bread},
			] },
			{ id: TowerBurger,        ordered: true,  items: [
				{type: Bread}, {type: Meat, state: Cooked}, {type: Cheese},
				{type: Bread}, {type: Meat, state: Cooked}, {type: Cheese}, {type: Bread},
			] },
		];
	}
}
