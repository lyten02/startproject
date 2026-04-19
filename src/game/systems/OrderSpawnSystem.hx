package game.systems;

import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Order;
import game.ecs.components.OrderQueue;
import game.orders.OrderConfig;

/**
 * Accumulates scaled dt; once the interval elapses and the queue has room,
 * spawns a new Order entity with a random DishType from the config pool.
 * RNG is injectable so specs stay deterministic.
 */
class OrderSpawnSystem implements ISystem {
	var config:OrderConfig;
	var rand:()->Float;

	public function new(config:OrderConfig, ?rand:()->Float) {
		this.config = config;
		this.rand   = rand != null ? rand : Math.random;
	}

	public function update(world:World, dt:Float):Void {
		var qEnt = findQueue(world);
		if (qEnt == null) return;
		var q = qEnt.get(OrderQueue);

		if (q.isFull()) { q.spawnTimerSec = 0; return; }

		q.spawnTimerSec += dt;
		while (q.spawnTimerSec >= config.baseSpawnIntervalSec && !q.isFull()) {
			q.spawnTimerSec -= config.baseSpawnIntervalSec;
			spawnOne(world, q);
		}
	}

	function spawnOne(world:World, q:OrderQueue):Void {
		if (config.dishes.length == 0) return;
		var idx = Std.int(rand() * config.dishes.length);
		if (idx < 0) idx = 0;
		if (idx >= config.dishes.length) idx = config.dishes.length - 1;
		var entry = config.dishes[idx];
		var e = world.create();
		e.add(new Order(entry.dishType, entry.patienceSec, entry.reward));
		q.orders.push(e);
	}

	static function findQueue(world:World):Entity {
		var qs = world.query(OrderQueue);
		return qs.length > 0 ? qs[0] : null;
	}
}
