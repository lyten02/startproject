package game.recipes;

import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Ingredient.IngredientType;

/**
 * Per-ingredient metadata loaded from res/data/ingredients.json.
 * Drives icon resolution, i18n, freshness defaults, and future state gating.
 */
typedef IngredientMeta = {
	var type:IngredientType;
	var id:String;            // snake_case id used in recipes.json refs
	var iconPath:String;      // base/raw resource path, e.g. "sprites/ingredients/bread"
	var iconPathByState:Map<IngredientState, String>; // optional per-state override; missing → iconPath
	var i18nKey:String;       // e.g. "ingredients.bread"
	var category:String;      // "base" | "protein" | "dairy" | "vegetable"
	var maxFreshness:Float;   // seconds until auto-spoil
	var allowedStates:Array<IngredientState>;
	@:optional var premiumVariant:String; // alt asset path, optional
};
