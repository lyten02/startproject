package game.recipes;

import utest.Assert;
import utest.Test;
import game.ecs.components.Dish.DishType;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate.PlateSlot;

class RecipeMatcherSpec extends Test {
	static function slot(t:IngredientType, ?s:IngredientState):PlateSlot {
		return { type: t, state: s != null ? s : Raw, freshness: 0, maxFreshness: 120 };
	}

	function testEmptyReturnsNull() {
		Assert.isNull(RecipeMatcher.match([]));
	}

	function testNullReturnsNull() {
		Assert.isNull(RecipeMatcher.match(null));
	}

	function testSandwichUnordered() {
		var r = RecipeMatcher.match([slot(Bread), slot(Cheese)]);
		Assert.notNull(r);
		Assert.equals(Sandwich, r.id);
	}

	function testSandwichReverseOrder() {
		var r = RecipeMatcher.match([slot(Cheese), slot(Bread)]);
		Assert.notNull(r);
		Assert.equals(Sandwich, r.id);
	}

	function testBruschettaRequiresChoppedTomato() {
		Assert.isNull(RecipeMatcher.match([slot(Bread), slot(Tomato, Raw)]));
		var r = RecipeMatcher.match([slot(Bread), slot(Tomato, Chopped)]);
		Assert.notNull(r);
		Assert.equals(Bruschetta, r.id);
	}

	function testClassicBurgerOrdered() {
		var r = RecipeMatcher.match([
			slot(Bread), slot(Meat, Cooked), slot(Lettuce), slot(Bread)
		]);
		Assert.notNull(r);
		Assert.equals(ClassicBurger, r.id);
	}

	function testClassicBurgerRawMeatFails() {
		var r = RecipeMatcher.match([
			slot(Bread), slot(Meat, Raw), slot(Lettuce), slot(Bread)
		]);
		Assert.isNull(r);
	}

	function testClassicBurgerWrongOrderFails() {
		var r = RecipeMatcher.match([
			slot(Meat, Cooked), slot(Bread), slot(Lettuce), slot(Bread)
		]);
		Assert.isNull(r);
	}

	function testCheeseBurgerPreferredOverClassic() {
		var r = RecipeMatcher.match([
			slot(Bread), slot(Meat, Cooked), slot(Cheese), slot(Bread)
		]);
		Assert.notNull(r);
		Assert.equals(CheeseBurger, r.id);
	}

	function testExcessBlocks() {
		Assert.isNull(RecipeMatcher.match([slot(Bread), slot(Cheese), slot(Tomato)]));
	}

	function testPartialBlocks() {
		Assert.isNull(RecipeMatcher.match([slot(Bread)]));
	}

	function testSpoiledBlocks() {
		Assert.isNull(RecipeMatcher.match([slot(Bread), slot(Cheese, Spoiled)]));
	}

	function testBurntBlocks() {
		Assert.isNull(RecipeMatcher.match([
			slot(Bread), slot(Meat, Burnt), slot(Lettuce), slot(Bread)
		]));
	}

	function testUnknownCombinationBlocks() {
		Assert.isNull(RecipeMatcher.match([slot(Onion), slot(Cucumber)]));
	}

	function testRoyalBurger() {
		var r = RecipeMatcher.match([
			slot(Bread), slot(Meat, Cooked), slot(Cheese),
			slot(Tomato, Chopped), slot(Lettuce), slot(Bread)
		]);
		Assert.notNull(r);
		Assert.equals(RoyalBurger, r.id);
	}

	function testRoyalBurgerRawTomatoFails() {
		Assert.isNull(RecipeMatcher.match([
			slot(Bread), slot(Meat, Cooked), slot(Cheese),
			slot(Tomato, Raw), slot(Lettuce), slot(Bread)
		]));
	}

	function testDoubleCheeseburger() {
		var r = RecipeMatcher.match([
			slot(Bread), slot(Meat, Cooked), slot(Cheese),
			slot(Meat, Cooked), slot(Cheese), slot(Bread)
		]);
		Assert.notNull(r);
		Assert.equals(DoubleCheeseburger, r.id);
	}

	function testTowerBurger() {
		var r = RecipeMatcher.match([
			slot(Bread), slot(Meat, Cooked), slot(Cheese),
			slot(Bread), slot(Meat, Cooked), slot(Cheese), slot(Bread)
		]);
		Assert.notNull(r);
		Assert.equals(TowerBurger, r.id);
	}

	function testTowerBurgerWrongOrderFails() {
		// Swap first Meat/Cheese pair
		Assert.isNull(RecipeMatcher.match([
			slot(Bread), slot(Cheese), slot(Meat, Cooked),
			slot(Bread), slot(Meat, Cooked), slot(Cheese), slot(Bread)
		]));
	}
}
