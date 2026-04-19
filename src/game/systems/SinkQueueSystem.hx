package game.systems;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Plate;
import game.ecs.components.PlateStand;
import game.ecs.components.SinkQueue;
import game.ecs.components.Station;
import game.ecs.components.Surface;
import game.ecs.components.Transform;

/**
 * Positions plates stacked in a sink's queue (visual spread), prunes plates
 * that have been picked up, and moves the bottom plate to the first free cell
 * of a PlateStand once it has been washed clean.
 */
class SinkQueueSystem implements ISystem {
	static inline var STACK_STEP:Float = 3;

	public function new() {}

	public function update(world:World, dt:Float):Void {
		for (sink in world.query(SinkQueue)) {
			var q  = sink.get(SinkQueue);
			var tr = sink.get(Transform);
			var co = sink.get(Collider);
			if (tr == null || co == null) continue;

			// Drop plates that were taken out of the sink.
			var i = q.plates.length - 1;
			while (i >= 0) {
				var p = q.plates[i];
				var car = p.get(Carryable);
				if (car != null && car.heldBy != null) q.plates.splice(i, 1);
				i--;
			}

			// Auto-transfer to stand is triggered by CookingSystem when washing
			// completes, NOT every time a clean plate sits in the sink.

			// Visual layout: each plate centred on the sink, bottom first.
			for (idx in 0...q.plates.length) {
				var plate = q.plates[idx];
				var ptr = plate.get(Transform);
				var pc  = plate.get(Collider);
				if (ptr == null || pc == null) continue;
				ptr.pos.x = tr.pos.x + (co.w - pc.w) * 0.5;
				ptr.pos.y = tr.pos.y + (co.h - pc.h) * 0.5 - idx * STACK_STEP;
			}
		}
	}

	public static function transferToStand(world:World, q:SinkQueue, plate:Entity):Void {
		tryMoveToStand(world, q, plate);
	}

	static function tryMoveToStand(world:World, q:SinkQueue, plate:Entity):Void {
		// Pass 1: first empty cell on any stand.
		for (stand in world.query(PlateStand)) {
			if (placeInEmptyCell(stand, plate)) { q.plates.shift(); return; }
		}
		// Pass 2: stack on the first existing plate in a stand.
		for (stand in world.query(PlateStand)) {
			if (stackOntoExisting(stand, plate)) { q.plates.shift(); return; }
		}
	}

	static function placeInEmptyCell(stand:Entity, plate:Entity):Bool {
		var surf = stand.get(Surface);
		var tr = stand.get(Transform);
		var co = stand.get(Collider);
		if (surf == null || tr == null || co == null) return false;
		var x0 = Std.int(tr.pos.x / Grid.CELL);
		var y0 = Std.int(tr.pos.y / Grid.CELL);
		var x1 = Std.int((tr.pos.x + co.w - 1) / Grid.CELL);
		var y1 = Std.int((tr.pos.y + co.h - 1) / Grid.CELL);
		for (cx in x0...x1 + 1) for (cy in y0...y1 + 1) {
			if (surf.occupantAt(cx, cy) == null) {
				var ptr = plate.get(Transform);
				var pc  = plate.get(Collider);
				if (ptr != null && pc != null) {
					ptr.pos.x = cx * Grid.CELL + (Grid.CELL - pc.w) * 0.5;
					ptr.pos.y = cy * Grid.CELL + (Grid.CELL - pc.h) * 0.5;
				}
				surf.place(cx, cy, plate);
				return true;
			}
		}
		return false;
	}

	static function stackOntoExisting(stand:Entity, plate:Entity):Bool {
		var surf = stand.get(Surface);
		var tr = stand.get(Transform);
		var co = stand.get(Collider);
		if (surf == null || tr == null || co == null) return false;
		var x0 = Std.int(tr.pos.x / Grid.CELL);
		var y0 = Std.int(tr.pos.y / Grid.CELL);
		var x1 = Std.int((tr.pos.x + co.w - 1) / Grid.CELL);
		var y1 = Std.int((tr.pos.y + co.h - 1) / Grid.CELL);
		for (cx in x0...x1 + 1) for (cy in y0...y1 + 1) {
			var occ = surf.occupantAt(cx, cy);
			if (occ == null) continue;
			var basePlate = occ.get(Plate);
			if (basePlate != null) {
				basePlate.stackedPlates.push(plate);
				return true;
			}
		}
		return false;
	}
}
