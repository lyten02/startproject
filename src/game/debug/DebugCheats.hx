package game.debug;

import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Dish;
import game.ecs.components.Hands;
import game.ecs.components.Order;
import game.ecs.components.OrderQueue;
import game.ecs.components.Plate;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;
import game.map.EntityFactory;
import game.systems.InteractActions;

/**
 * Dev shortcuts triggered from GameplayState under `#if debug`. Keeps the
 * state class small and groups cheat helpers in one place.
 */
class DebugCheats {
	/**
	 * Spawn a ready plate carrying the most recently queued order's dish and
	 * attach it to the player's hands. No-op if hands are occupied or the
	 * queue is empty — we don't want to silently discard held items.
	 */
	public static function spawnLastOrderedDish(world:World):Void {
		var players = world.query(PlayerControlled);
		if (players.length == 0) return;
		var player = players[0];
		var hands  = player.get(Hands);
		if (hands == null || hands.held != null) return;

		var qs = world.query(OrderQueue);
		if (qs.length == 0) return;
		var q = qs[0].get(OrderQueue);
		if (q.orders.length == 0) return;

		var last = q.orders[q.orders.length - 1];
		var o = last.get(Order);
		if (o == null) return;

		var tr = player.get(Transform);
		var co = player.get(Collider);
		var side:Float = 20;
		var px = tr.pos.x + co.w * 0.5 - side * 0.5;
		var py = tr.pos.y + co.h * 0.5 - side * 0.5;

		var plate = EntityFactory.spawnPlate(world, px, py);
		plate.get(Plate).dish = new Dish(o.dishType, []);
		InteractActions.attachToHands(world, player, hands, plate);
	}
}
