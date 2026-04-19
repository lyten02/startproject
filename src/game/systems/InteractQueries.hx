package game.systems;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Dispenser;
import game.ecs.components.Facing;
import game.ecs.components.InFlight;
import game.ecs.components.Surface;
import game.ecs.components.Transform;
import game.ecs.components.Trash;

/** Cell-level lookup helpers used by InteractSystem. Pure (Grid + ECS only). */
class InteractQueries {
	/** Catch radius around player's centre for intercepting airborne items (px). */
	public static inline var CATCH_RADIUS:Float = 1.5 * Grid.CELL;

	/** Nearest airborne Carryable within CATCH_RADIUS of (px, py); null if none. */
	public static function findCatchableNear(world:World, px:Float, py:Float):Entity {
		var r2 = CATCH_RADIUS * CATCH_RADIUS;
		var best:Entity = null;
		var bestD2 = r2;
		for (e in world.query(Carryable)) {
			if (!e.has(InFlight)) continue;
			var car = e.get(Carryable);
			if (car.heldBy != null) continue;
			var tr = e.get(Transform);
			var co = e.get(Collider);
			if (tr == null || co == null) continue;
			var cx = tr.pos.x + co.w * 0.5;
			var cy = tr.pos.y + co.h * 0.5;
			var dx = cx - px;
			var dy = cy - py;
			var d2 = dx * dx + dy * dy;
			if (d2 <= bestD2) { bestD2 = d2; best = e; }
		}
		return best;
	}

	/** Player's centre point (px). */
	public static inline function playerCentre(player:Entity):{x:Float, y:Float} {
		var tr = player.get(Transform);
		var co = player.get(Collider);
		return { x: tr.pos.x + co.w * 0.5, y: tr.pos.y + co.h * 0.5 };
	}

	public static function facingCell(player:Entity):{x:Int, y:Int} {
		var tr = player.get(Transform);
		var co = player.get(Collider);
		var fc = player.get(Facing);
		var cx = Std.int((tr.pos.x + co.w * 0.5) / Grid.CELL);
		var cy = Std.int((tr.pos.y + co.h * 0.5) / Grid.CELL);
		return { x: cx + fc.dx, y: cy + fc.dy };
	}

	public static function cellInSurface(surf:Entity, cx:Int, cy:Int):Bool {
		var tr = surf.get(Transform);
		var co = surf.get(Collider);
		var x0 = Std.int(tr.pos.x / Grid.CELL);
		var y0 = Std.int(tr.pos.y / Grid.CELL);
		var x1 = Std.int((tr.pos.x + co.w - 1) / Grid.CELL);
		var y1 = Std.int((tr.pos.y + co.h - 1) / Grid.CELL);
		return cx >= x0 && cx <= x1 && cy >= y0 && cy <= y1;
	}

	public static function findCarryableAtCell(world:World, cx:Int, cy:Int):Entity {
		for (e in world.query(Carryable)) {
			var car = e.get(Carryable);
			if (car.heldBy != null) continue;
			var tr = e.get(Transform);
			var co = e.get(Collider);
			if (tr == null || co == null) continue;
			var ecx = Std.int((tr.pos.x + co.w * 0.5) / Grid.CELL);
			var ecy = Std.int((tr.pos.y + co.h * 0.5) / Grid.CELL);
			if (ecx == cx && ecy == cy) return e;
		}
		return null;
	}

	public static function findSurfaceAtCell(world:World, cx:Int, cy:Int):Entity {
		for (e in world.query(Surface)) if (cellInSurface(e, cx, cy)) return e;
		return null;
	}

	public static function findDispenserAtCell(world:World, cx:Int, cy:Int):Entity {
		for (e in world.query(Dispenser)) if (cellInSurface(e, cx, cy)) return e;
		return null;
	}

	public static function findTrashAtCell(world:World, cx:Int, cy:Int):Entity {
		for (e in world.query(Trash)) if (cellInSurface(e, cx, cy)) return e;
		return null;
	}

	/** Target cell first; if taken, try N/S/E/W inside the same Surface; null = all busy. */
	public static function freeSlotNear(surf:Entity, sc:Surface, cx:Int, cy:Int):{cx:Int, cy:Int} {
		if (sc.occupantAt(cx, cy) == null) return { cx: cx, cy: cy };
		var offsets = [[0, -1], [0, 1], [-1, 0], [1, 0]];
		for (o in offsets) {
			var nx = cx + o[0], ny = cy + o[1];
			if (!cellInSurface(surf, nx, ny)) continue;
			if (sc.occupantAt(nx, ny) == null) return { cx: nx, cy: ny };
		}
		return null;
	}
}
