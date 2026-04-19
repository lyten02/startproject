package game.recipes;

import game.ecs.components.Ingredient;
import utest.Assert;
import utest.Test;

class IngredientCatalogSpec extends Test {
	static inline var BREAD_ONLY = '{ "ingredients": [
		{ "id": "bread", "type": "Bread", "icon_path": "x", "i18n_key": "ingredients.bread",
		  "category": "base", "default_freshness_seconds": 200, "allowed_states": ["raw"] }
	] }';

	function teardown() IngredientCatalog.reset();

	function testParsesBasic() {
		IngredientCatalog.parse(BREAD_ONLY);
		var m = IngredientCatalog.get(Bread);
		Assert.notNull(m);
		Assert.equals("bread", m.id);
		Assert.equals("x", m.iconPath);
		Assert.equals(200.0, m.maxFreshness);
		Assert.equals(1, m.allowedStates.length);
		Assert.equals(Raw, m.allowedStates[0]);
	}

	function testMaxFreshnessFallback() {
		Assert.equals(IngredientCatalog.DEFAULT_FRESHNESS, IngredientCatalog.getMaxFreshness(Bread));
	}

	function testGetMaxFreshnessFromCatalog() {
		IngredientCatalog.parse(BREAD_ONLY);
		Assert.equals(200.0, IngredientCatalog.getMaxFreshness(Bread));
	}

	function testTypeByIdLookup() {
		IngredientCatalog.parse(BREAD_ONLY);
		Assert.equals(Bread, IngredientCatalog.typeById("bread"));
		Assert.isNull(IngredientCatalog.typeById("meat"));
	}

	function testUnknownTypeThrows() {
		Assert.raises(() -> IngredientCatalog.parse(
			'{ "ingredients": [{ "id": "xyz", "type": "Xyz" }] }'
		));
	}

	function testDuplicateTypeThrows() {
		Assert.raises(() -> IngredientCatalog.parse(
			'{ "ingredients": [
				{ "id": "a", "type": "Bread" },
				{ "id": "b", "type": "Bread" }
			] }'
		));
	}

	function testDuplicateIdThrows() {
		Assert.raises(() -> IngredientCatalog.parse(
			'{ "ingredients": [
				{ "id": "bread", "type": "Bread" },
				{ "id": "bread", "type": "Meat" }
			] }'
		));
	}

	function testUnknownStateThrows() {
		Assert.raises(() -> IngredientCatalog.parse(
			'{ "ingredients": [
				{ "id": "bread", "type": "Bread", "allowed_states": ["explosive"] }
			] }'
		));
	}

	function testEmptyJsonThrows() {
		Assert.raises(() -> IngredientCatalog.parse("null"));
	}

	function testMissingIngredientsArrayThrows() {
		Assert.raises(() -> IngredientCatalog.parse("{}"));
	}

	function testOptionalFieldsDefault() {
		IngredientCatalog.parse('{ "ingredients": [{ "id": "cheese", "type": "Cheese" }] }');
		var m = IngredientCatalog.get(Cheese);
		Assert.equals("sprites/ingredients/cheese", m.iconPath);
		Assert.equals("ingredients.cheese", m.i18nKey);
		Assert.equals("base", m.category);
		Assert.equals(IngredientCatalog.DEFAULT_FRESHNESS, m.maxFreshness);
	}
}
