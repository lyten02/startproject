package game.recipes;

import game.ecs.components.Dish.DishType;

/**
 * Per-recipe metadata loaded from res/data/recipes.json. Lives next to
 * `Recipe` (which is hot-path) so the matcher typedef stays minimal.
 * `positions` aligns to Recipe.items after `count` expansion; empty means
 * "no authoring info, assume sequential".
 */
typedef RecipeMeta = {
	var id:DishType;
	var i18nKey:String;                  // overrides GameI18n default resolver
	@:optional var resultIconPath:String; // null = use tint-based rendering
	var allowedContainers:Array<String>; // "plate" | "hands" | "table" (v1: plate only)
	var maxIngredientsTotal:Int;         // -1 = unlimited
	var fallbackBehavior:String;         // "block" (v1 only) | "downgrade_to_simple" | "create_trash"
	var positions:Array<Int>;            // position_index per expanded items slot
};
