package game.systems;

import game.core.Grid;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Facing;
import game.ecs.components.Hands;
import game.ecs.components.Transform;

/**
 * Snaps held items to the player's hands each frame:
 *   item.pos = player center + facing * HAND_OFFSET - item halfSize
 */
class CarryFollowSystem implements ISystem {
	static inline var HAND_OFFSET:Float = 20;

	public function new() {}

	public function update(world:World, dt:Float):Void {
		for (e in world.query(Hands)) {
			var hands = e.get(Hands);
			if (hands.held == null) continue;

			var ptr = e.get(Transform);
			var pc  = e.get(Collider);
			var fc  = e.get(Facing);
			if (ptr == null || pc == null || fc == null) continue;

			var item = hands.held;
			var itr  = item.get(Transform);
			var ic   = item.get(Collider);
			if (itr == null || ic == null) continue;

			var cx = ptr.pos.x + pc.w * 0.5;
			var cy = ptr.pos.y + pc.h * 0.5;
			itr.pos.x = cx + fc.dx * (Grid.CELL * 0.5 + HAND_OFFSET) - ic.w * 0.5;
			itr.pos.y = cy + fc.dy * (Grid.CELL * 0.5 + HAND_OFFSET) - ic.h * 0.5;
		}
	}
}
