package game.orders;

import game.ecs.components.Dish.DishType;
import game.orders.OrderConfig.OrderConfigEntry;

/**
 * Pure JSON → OrderConfig. Validates dish IDs against the DishType enum so
 * misspelled names fail fast at load, not at spawn.
 */
class OrderConfigLoader {
	public static function parse(json:String):OrderConfig {
		var raw:Dynamic = haxe.Json.parse(json);
		if (raw == null) throw "OrderConfigLoader: empty JSON";
		if (raw.base_spawn_interval_sec == null) throw 'OrderConfigLoader: missing "base_spawn_interval_sec"';
		if (raw.max_queue_size == null)          throw 'OrderConfigLoader: missing "max_queue_size"';
		if (raw.dishes == null)                  throw 'OrderConfigLoader: missing "dishes" array';

		var interval:Float = raw.base_spawn_interval_sec;
		var maxSize:Int    = raw.max_queue_size;
		if (interval <= 0) throw 'OrderConfigLoader: "base_spawn_interval_sec" must be > 0';
		if (maxSize <= 0)  throw 'OrderConfigLoader: "max_queue_size" must be > 0';

		var list:Array<Dynamic> = raw.dishes;
		if (list.length == 0) throw 'OrderConfigLoader: "dishes" must not be empty';

		var dishes:Array<OrderConfigEntry> = [];
		for (i in 0...list.length) {
			var e = list[i];
			if (e.dish_id == null)      throw 'OrderConfigLoader: dishes[$i] missing "dish_id"';
			if (e.patience_sec == null) throw 'OrderConfigLoader: dishes[$i] missing "patience_sec"';
			if (e.reward == null)       throw 'OrderConfigLoader: dishes[$i] missing "reward"';
			var id:DishType = try Type.createEnum(DishType, e.dish_id) catch (_:Dynamic)
				throw 'OrderConfigLoader: dishes[$i] unknown dish_id "${e.dish_id}"';
			var patience:Float = e.patience_sec;
			if (patience <= 0) throw 'OrderConfigLoader: dishes[$i] patience_sec must be > 0';
			dishes.push({ dishType: id, patienceSec: patience, reward: e.reward });
		}

		return {
			baseSpawnIntervalSec: interval,
			maxQueueSize:         maxSize,
			dishes:               dishes,
		};
	}
}
