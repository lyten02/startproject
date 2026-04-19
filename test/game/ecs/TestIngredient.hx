package game.ecs;

import utest.Assert;
import utest.Test;
import game.ecs.components.Ingredient;

class TestIngredient extends Test {
	function testDefaults() {
		var ing = new Ingredient(Tomato);
		Assert.equals(Tomato, ing.type);
		Assert.equals(Raw, ing.state);
		Assert.floatEquals(0, ing.freshness);
		Assert.floatEquals(0, ing.processedTime);
		Assert.floatEquals(120, ing.maxFreshness);
	}

	function testCustomMaxFreshness() {
		var ing = new Ingredient(Meat, 60);
		Assert.floatEquals(60, ing.maxFreshness);
	}

	function testStateMutable() {
		var ing = new Ingredient(Bread);
		ing.state = Cooked;
		Assert.equals(Cooked, ing.state);
	}
}
