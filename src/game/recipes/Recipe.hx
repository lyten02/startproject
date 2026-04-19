package game.recipes;

import game.ecs.components.Dish.DishType;
import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Ingredient.IngredientType;

/**
 * One ingredient requirement inside a recipe.
 * `state == null` means "any state matches" (wildcard).
 */
typedef RecipeIngredient = {
	type:IngredientType,
	?state:IngredientState,
};

/**
 * Recipe definition. `ordered = true` → items must appear in the same order
 * in plate.contents; otherwise the set match is by multiset equality.
 * Display name comes from I18n (`recipes.<snake_case_of_id>`) — see GameI18n.
 */
typedef Recipe = {
	id:DishType,
	ordered:Bool,
	items:Array<RecipeIngredient>,
};
