package game.recipes;

import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Plate.PlateSlot;
import game.recipes.Recipe;

/**
 * Pure recipe-matching logic. No Heaps/ECS deps — safe to use from tests.
 * Returns the best-matching recipe for given plate contents, or null.
 */
class RecipeMatcher {
	public static function match(contents:Array<PlateSlot>):Null<Recipe> {
		if (contents == null || contents.length == 0) return null;
		for (slot in contents) {
			if (slot.state == Spoiled || slot.state == Burnt) return null;
		}

		var candidates = RecipeBook.ALL.filter(r -> r.items.length == contents.length);
		candidates.sort(byLengthDescThenSpecificityDesc);

		for (r in candidates) {
			if (r.ordered) {
				if (matchesOrdered(contents, r)) return r;
			} else {
				if (matchesMultiset(contents, r)) return r;
			}
		}
		return null;
	}

	static function matchesOrdered(contents:Array<PlateSlot>, r:Recipe):Bool {
		for (i in 0...contents.length) {
			if (!slotMatches(contents[i], r.items[i])) return false;
		}
		return true;
	}

	static function matchesMultiset(contents:Array<PlateSlot>, r:Recipe):Bool {
		var remaining = r.items.copy();
		for (slot in contents) {
			var idx = -1;
			for (i in 0...remaining.length) {
				if (slotMatches(slot, remaining[i])) { idx = i; break; }
			}
			if (idx < 0) return false;
			remaining.splice(idx, 1);
		}
		return remaining.length == 0;
	}

	static inline function slotMatches(slot:PlateSlot, req:RecipeIngredient):Bool {
		if (slot.type != req.type) return false;
		return req.state == null || slot.state == req.state;
	}

	static function byLengthDescThenSpecificityDesc(a:Recipe, b:Recipe):Int {
		if (a.items.length != b.items.length) return b.items.length - a.items.length;
		return specificity(b) - specificity(a);
	}

	static inline function specificity(r:Recipe):Int {
		var s = 0;
		for (it in r.items) if (it.state != null) s++;
		return s;
	}
}
