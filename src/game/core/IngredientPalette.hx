package game.core;

import game.ecs.components.Ingredient.IngredientState;

/** Pure colour mapping for ingredient state + freshness. No engine deps. */
class IngredientPalette {
	/** Sprite RGB multiply per state. */
	public static function tintFor(state:IngredientState):Int {
		return switch state {
			case Raw:     0xFFFFFF;
			case Chopped: 0xDDDDFF;
			case Cooked:  0xFFD070; // fried/pan-cooked — golden
			case Boiled:  0x9EC9FF; // boiled/stewed — pale blue
			case Burnt:   0x505050;
			case Spoiled: 0x5A3A1E; // dark brown — rotten
		}
	}

	/** Debug-label colour for the freshness readout (green → yellow → red). */
	public static function freshnessColor(freshness:Float, max:Float):Int {
		if (max <= 0) return 0x7CFC8A;
		var t = freshness / max;
		if (t < 0.5) return 0x7CFC8A;
		if (t < 0.8) return 0xFFD070;
		return 0xFF6060;
	}
}
