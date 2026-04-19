package game.recipes;

import game.ecs.components.Dish.DishType;
import game.ecs.components.Ingredient;
import utest.Assert;
import utest.Test;

class RecipeLoaderSpec extends Test {
	static inline var BASE_INGREDIENTS = '{ "ingredients": [
		{ "id": "bread",   "type": "Bread" },
		{ "id": "meat",    "type": "Meat" },
		{ "id": "cheese",  "type": "Cheese" },
		{ "id": "tomato",  "type": "Tomato" },
		{ "id": "lettuce", "type": "Lettuce" }
	] }';

	function setup()   IngredientCatalog.parse(BASE_INGREDIENTS);
	function teardown() IngredientCatalog.reset();

	function testParsesSandwich() {
		var loaded = RecipeLoader.parse('{ "recipes": [{
			"id": "Sandwich",
			"i18n_key": "recipes.sandwich",
			"strict_order": false,
			"ingredients": [
				{ "ingredient_id": "bread",  "required_state": null },
				{ "ingredient_id": "cheese", "required_state": null }
			]
		}] }');
		Assert.equals(1, loaded.recipes.length);
		var r = loaded.recipes[0];
		Assert.equals(Sandwich, r.id);
		Assert.isFalse(r.ordered);
		Assert.equals(2, r.items.length);
		Assert.equals(Bread, r.items[0].type);
		Assert.equals(Cheese, r.items[1].type);
		Assert.isNull(r.items[0].state);
	}

	function testParsesBurgerOrderedWithState() {
		var loaded = RecipeLoader.parse('{ "recipes": [{
			"id": "ClassicBurger",
			"i18n_key": "recipes.classic_burger",
			"strict_order": true,
			"ingredients": [
				{ "ingredient_id": "bread" },
				{ "ingredient_id": "meat", "required_state": "cooked" },
				{ "ingredient_id": "lettuce" },
				{ "ingredient_id": "bread" }
			]
		}] }');
		var r = loaded.recipes[0];
		Assert.isTrue(r.ordered);
		Assert.equals(4, r.items.length);
		Assert.equals(Meat, r.items[1].type);
		Assert.equals(Cooked, r.items[1].state);
	}

	function testCountExpandsEntries() {
		var loaded = RecipeLoader.parse('{ "recipes": [{
			"id": "Sandwich",
			"i18n_key": "k",
			"strict_order": false,
			"ingredients": [
				{ "ingredient_id": "bread", "count": 2, "position_index": 0 },
				{ "ingredient_id": "cheese", "count": 1, "position_index": 1 }
			]
		}] }');
		var r = loaded.recipes[0];
		Assert.equals(3, r.items.length);
		Assert.equals(Bread,  r.items[0].type);
		Assert.equals(Bread,  r.items[1].type);
		Assert.equals(Cheese, r.items[2].type);
		var meta = loaded.meta.get(Sandwich);
		Assert.same([0, 0, 1], meta.positions);
	}

	function testMetaDefaults() {
		var loaded = RecipeLoader.parse('{ "recipes": [{
			"id": "Sandwich", "strict_order": false,
			"ingredients": [{ "ingredient_id": "bread" }, { "ingredient_id": "cheese" }]
		}] }');
		var m = loaded.meta.get(Sandwich);
		Assert.equals("recipes.sandwich", m.i18nKey);
		Assert.equals(1, m.allowedContainers.length);
		Assert.equals("plate", m.allowedContainers[0]);
		Assert.equals("block", m.fallbackBehavior);
	}

	function testUnknownRecipeIdThrows() {
		Assert.raises(() -> RecipeLoader.parse('{ "recipes": [{
			"id": "MegaBurger", "strict_order": false,
			"ingredients": [{ "ingredient_id": "bread" }]
		}] }'));
	}

	function testDuplicateRecipeIdThrows() {
		Assert.raises(() -> RecipeLoader.parse('{ "recipes": [
			{ "id": "Sandwich", "strict_order": false, "ingredients": [{ "ingredient_id": "bread" }] },
			{ "id": "Sandwich", "strict_order": false, "ingredients": [{ "ingredient_id": "cheese" }] }
		] }'));
	}

	function testUnknownIngredientRefThrows() {
		Assert.raises(() -> RecipeLoader.parse('{ "recipes": [{
			"id": "Sandwich", "strict_order": false,
			"ingredients": [{ "ingredient_id": "pickle" }]
		}] }'));
	}

	function testUnknownStateThrows() {
		Assert.raises(() -> RecipeLoader.parse('{ "recipes": [{
			"id": "Sandwich", "strict_order": false,
			"ingredients": [{ "ingredient_id": "bread", "required_state": "frozen" }]
		}] }'));
	}

	function testMissingRecipesArrayThrows() {
		Assert.raises(() -> RecipeLoader.parse("{}"));
	}

	function testEmptyJsonThrows() {
		Assert.raises(() -> RecipeLoader.parse("null"));
	}
}
