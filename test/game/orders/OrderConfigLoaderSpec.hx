package game.orders;

import game.ecs.components.Dish.DishType;
import utest.Assert;
import utest.Test;

class OrderConfigLoaderSpec extends Test {
	static inline var VALID = '{
		"base_spawn_interval_sec": 20,
		"max_queue_size": 4,
		"dishes": [
			{ "dish_id": "Sandwich",      "patience_sec": 30, "reward": 10 },
			{ "dish_id": "ClassicBurger", "patience_sec": 60, "reward": 20 }
		]
	}';

	function testParsesAllFields() {
		var c = OrderConfigLoader.parse(VALID);
		Assert.equals(20.0, c.baseSpawnIntervalSec);
		Assert.equals(4, c.maxQueueSize);
		Assert.equals(2, c.dishes.length);
		Assert.equals(Sandwich, c.dishes[0].dishType);
		Assert.equals(30.0, c.dishes[0].patienceSec);
		Assert.equals(10, c.dishes[0].reward);
		Assert.equals(ClassicBurger, c.dishes[1].dishType);
	}

	function testMissingIntervalThrows() {
		Assert.raises(() -> OrderConfigLoader.parse('{ "max_queue_size": 4, "dishes": [] }'));
	}

	function testMissingMaxSizeThrows() {
		Assert.raises(() -> OrderConfigLoader.parse('{ "base_spawn_interval_sec": 20, "dishes": [] }'));
	}

	function testMissingDishesThrows() {
		Assert.raises(() -> OrderConfigLoader.parse('{ "base_spawn_interval_sec": 20, "max_queue_size": 4 }'));
	}

	function testEmptyDishesThrows() {
		Assert.raises(() -> OrderConfigLoader.parse('{
			"base_spawn_interval_sec": 20, "max_queue_size": 4, "dishes": []
		}'));
	}

	function testUnknownDishIdThrows() {
		Assert.raises(() -> OrderConfigLoader.parse('{
			"base_spawn_interval_sec": 20, "max_queue_size": 4,
			"dishes": [{ "dish_id": "MegaBurger", "patience_sec": 30, "reward": 10 }]
		}'));
	}

	function testNegativeIntervalThrows() {
		Assert.raises(() -> OrderConfigLoader.parse('{
			"base_spawn_interval_sec": -1, "max_queue_size": 4,
			"dishes": [{ "dish_id": "Sandwich", "patience_sec": 30, "reward": 10 }]
		}'));
	}

	function testNegativePatienceThrows() {
		Assert.raises(() -> OrderConfigLoader.parse('{
			"base_spawn_interval_sec": 20, "max_queue_size": 4,
			"dishes": [{ "dish_id": "Sandwich", "patience_sec": -5, "reward": 10 }]
		}'));
	}

	function testEmptyJsonThrows() {
		Assert.raises(() -> OrderConfigLoader.parse("null"));
	}
}
