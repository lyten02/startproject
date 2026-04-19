package game.core;

import utest.Assert;
import utest.Test;

class TestIngredientPalette extends Test {
	function testTintPerState() {
		Assert.equals(0xFFFFFF, IngredientPalette.tintFor(Raw));
		Assert.equals(0xFFD070, IngredientPalette.tintFor(Cooked));
		Assert.equals(0x505050, IngredientPalette.tintFor(Burnt));
		Assert.equals(0x5A3A1E, IngredientPalette.tintFor(Spoiled));
	}

	function testFreshnessGreenYellowRed() {
		Assert.equals(0x7CFC8A, IngredientPalette.freshnessColor(10, 100));  // 10% → green
		Assert.equals(0xFFD070, IngredientPalette.freshnessColor(60, 100));  // 60% → yellow
		Assert.equals(0xFF6060, IngredientPalette.freshnessColor(90, 100));  // 90% → red
	}

	function testFreshnessGuardZeroMax() {
		Assert.equals(0x7CFC8A, IngredientPalette.freshnessColor(10, 0));
	}
}
