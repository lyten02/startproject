package game.systems;

import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Plate;
import game.ecs.components.Transform;

/**
 * Makes Plate.stackedPlates follow the base plate visually. Each stacked plate
 * is positioned at the base's Transform with a small per-level y-offset so the
 * pile reads as layered. Also evicts any stacked plate that got picked up
 * directly (heldBy != null) so the stack stays in sync.
 */
class PlateStackLayoutSystem implements ISystem {
	static inline var STEP:Float = 3;

	public function new() {}

	public function update(world:World, dt:Float):Void {
		for (base in world.query(Plate)) {
			var p = base.get(Plate);
			// Evict directly-held stacked plates.
			var i = p.stackedPlates.length - 1;
			while (i >= 0) {
				var sp = p.stackedPlates[i];
				var car = sp.get(Carryable);
				if (car != null && car.heldBy != null) p.stackedPlates.splice(i, 1);
				i--;
			}
			if (p.stackedPlates.length == 0) continue;

			var baseTr = base.get(Transform);
			var baseCo = base.get(Collider);
			if (baseTr == null || baseCo == null) continue;

			for (idx in 0...p.stackedPlates.length) {
				var plate = p.stackedPlates[idx];
				var ptr = plate.get(Transform);
				var pc  = plate.get(Collider);
				if (ptr == null || pc == null) continue;
				ptr.pos.x = baseTr.pos.x + (baseCo.w - pc.w) * 0.5;
				ptr.pos.y = baseTr.pos.y + (baseCo.h - pc.h) * 0.5 - (idx + 1) * STEP;
			}
		}
	}
}
