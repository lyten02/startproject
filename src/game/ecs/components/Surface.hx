package game.ecs.components;

import game.ecs.Entity;
import haxe.ds.StringMap;

/**
 * Placement surface. Tracks occupancy per grid cell (key "cx,cy"), so a multi-cell
 * surface (e.g. 20×4 prep table) can hold one item per cell, not one for the whole
 * table. Items are centered in the cell they were placed at, not at the Surface
 * geometric center.
 */
class Surface implements Component {
	var slots:StringMap<Entity>;

	public function new() {
		this.slots = new StringMap();
	}

	public inline function occupantAt(cx:Int, cy:Int):Entity {
		return slots.get(cx + "," + cy);
	}

	public inline function place(cx:Int, cy:Int, e:Entity):Void {
		slots.set(cx + "," + cy, e);
	}

	public inline function clear(cx:Int, cy:Int):Void {
		slots.remove(cx + "," + cy);
	}

	/** Slow path — used on pickup when we don't know which cell the item sat on. */
	public function cellOf(e:Entity):{cx:Int, cy:Int} {
		for (k in slots.keys()) {
			if (slots.get(k) == e) {
				var parts = k.split(",");
				return { cx: Std.parseInt(parts[0]), cy: Std.parseInt(parts[1]) };
			}
		}
		return null;
	}
}
