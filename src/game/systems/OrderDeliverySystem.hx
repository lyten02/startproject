package game.systems;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.ActionFeedback;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.GameStats;
import game.ecs.components.InFlight;
import game.ecs.components.Order;
import game.ecs.components.OrderQueue;
import game.ecs.components.Plate;
import game.ecs.components.PlayerControlled;
import game.ecs.components.ServeWindow;
import game.ecs.components.Surface;
import game.ecs.components.Transform;

/**
 * Each frame, scans plates sitting (not held, not flying) on a ServeWindow
 * surface. If the plate carries a finished Dish and a matching Order exists
 * in the queue, removes both (FIFO match on identical dishType) and posts
 * an ActionFeedback message to the player.
 */
class OrderDeliverySystem implements ISystem {
	public function new() {}

	public function update(world:World, _:Float):Void {
		var qs = world.query(OrderQueue);
		if (qs.length == 0) return;
		var q = qs[0].get(OrderQueue);
		if (q.orders.length == 0) return;

		for (srv in world.query(ServeWindow)) scanSurface(world, q, srv);
	}

	function scanSurface(world:World, q:OrderQueue, srv:Entity):Void {
		for (plate in world.query(Plate)) {
			var car = plate.get(Carryable);
			if (car == null || car.heldBy != null) continue;
			if (plate.has(InFlight)) continue;
			var p = plate.get(Plate);
			if (p.dish == null) continue;
			if (!plateOnSurface(plate, srv)) continue;

			var idx = findOrderIndex(q, p.dish.type);
			if (idx < 0) continue;

			var orderEnt = q.orders.splice(idx, 1)[0];
			var order = orderEnt.get(Order);
			recordStats(world, order != null ? order.reward : 0);
			world.destroy(orderEnt);
			releaseSurfaceSlot(srv, plate);
			EntityDestroyer.destroy(world, plate);
			notifyPlayer(world, "messages.order_served");
		}
	}

	static function plateOnSurface(plate:Entity, srv:Entity):Bool {
		var tr = plate.get(Transform);
		var co = plate.get(Collider);
		if (tr == null || co == null) return false;
		var cx = Std.int((tr.pos.x + co.w * 0.5) / Grid.CELL);
		var cy = Std.int((tr.pos.y + co.h * 0.5) / Grid.CELL);
		return InteractQueries.cellInSurface(srv, cx, cy);
	}

	static function findOrderIndex(q:OrderQueue, dt:game.ecs.components.Dish.DishType):Int {
		for (i in 0...q.orders.length) {
			var o = q.orders[i].get(Order);
			if (o != null && o.dishType == dt) return i;
		}
		return -1;
	}

	static function releaseSurfaceSlot(srv:Entity, plate:Entity):Void {
		var sc = srv.get(Surface);
		if (sc == null) return;
		var at = sc.cellOf(plate);
		if (at != null) sc.clear(at.cx, at.cy);
	}

	static function recordStats(world:World, reward:Int):Void {
		var all = world.query(GameStats);
		if (all.length == 0) return;
		all[0].get(GameStats).recordServed(reward);
	}

	static function notifyPlayer(world:World, key:String):Void {
		var players = world.query(PlayerControlled);
		if (players.length == 0) return;
		var fb = players[0].get(ActionFeedback);
		if (fb != null) fb.set(key, 1.2, 0x7CFC8A);
	}
}
