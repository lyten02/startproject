package game.orders;

import game.ecs.components.Dish.DishType;

/** One entry = one dish available to spawn as an order. */
typedef OrderConfigEntry = {
	dishType:DishType,
	patienceSec:Float,
	reward:Int,
};

/**
 * Parsed order-reception tuning. `baseSpawnIntervalSec` is the idle period
 * between spawns; `maxQueueSize` caps the on-screen queue. `dishes` is the
 * pool sampled uniformly at random for each new order.
 */
typedef OrderConfig = {
	baseSpawnIntervalSec:Float,
	maxQueueSize:Int,
	dishes:Array<OrderConfigEntry>,
};
