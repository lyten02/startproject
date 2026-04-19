package game.systems;

import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.ActionFeedback;
import game.ecs.components.GameStats;
import game.ecs.components.Order;
import game.ecs.components.OrderQueue;
import game.ecs.components.PlayerControlled;

/**
 * Ticks down `patienceSec` (clamped at 0) and accumulates `ageSec` for every
 * active Order. When patience fully drains, the order is removed from the
 * OrderQueue + world and a `messages.order_expired` feedback is posted to
 * the player.
 */
class OrderPatienceSystem implements ISystem {
	public function new() {}

	public function update(world:World, dt:Float):Void {
		var qs = world.query(OrderQueue);
		if (qs.length == 0) return;
		var q = qs[0].get(OrderQueue);
		if (q.orders.length == 0) return;

		var expired:Array<Entity> = null;
		for (e in q.orders) {
			var o = e.get(Order);
			if (o == null) continue;
			o.ageSec += dt;
			o.patienceSec -= dt;
			if (o.patienceSec <= 0) {
				o.patienceSec = 0;
				if (expired == null) expired = [];
				expired.push(e);
			}
		}
		if (expired == null) return;

		for (e in expired) {
			q.orders.remove(e);
			world.destroy(e);
		}
		recordFailed(world, expired.length);
		notifyExpired(world);
	}

	static function recordFailed(world:World, count:Int):Void {
		var all = world.query(GameStats);
		if (all.length == 0) return;
		var s = all[0].get(GameStats);
		for (_ in 0...count) s.recordFailed();
	}

	static function notifyExpired(world:World):Void {
		var players = world.query(PlayerControlled);
		if (players.length == 0) return;
		var fb = players[0].get(ActionFeedback);
		if (fb != null) fb.set("messages.order_expired", 1.8, 0xFF6060);
	}
}
