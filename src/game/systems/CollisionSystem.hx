package game.systems;

import game.core.AABB;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;

/**
 * Resolves Velocity against solid Colliders. Separate-axis AABB so entities
 * slide along obstacles. Also clamps to [0, boundsW] × [0, boundsH].
 * Pure logic — no engine calls; takes bounds as parameters.
 */
class CollisionSystem implements ISystem {
	static inline var NUDGE_PX:Float = 8;

	public var boundsW:Float = 1920;
	public var boundsH:Float = 1080;

	public function new() {}

	public function update(world:World, dt:Float):Void {
		var solids = solidsOf(world);

		for (e in world.entities) {
			var vel = e.get(Velocity);
			var col = e.get(Collider);
			var tr  = e.get(Transform);
			if (vel == null || tr == null || col == null) continue;
			var isPlayer = e.has(PlayerControlled);

			var preX = tr.pos.x;
			tr.pos.x += vel.v.x * dt;
			clampX(tr, col);
			resolveAxis(tr, col, solids, vel.v.x, true);
			if (isPlayer && vel.v.x != 0 && Math.abs(tr.pos.x - preX) < 0.5)
				cornerSlide(tr, col, solids, vel, true);

			var preY = tr.pos.y;
			tr.pos.y += vel.v.y * dt;
			clampY(tr, col);
			resolveAxis(tr, col, solids, vel.v.y, false);
			if (isPlayer && vel.v.y != 0 && Math.abs(tr.pos.y - preY) < 0.5)
				cornerSlide(tr, col, solids, vel, false);
		}
	}

	/** Shift the perpendicular axis by ±NUDGE to slip past a corner, then retry. */
	function cornerSlide(tr:Transform, col:Collider, solids:Array<Entity>, vel:Velocity, xAxis:Bool):Void {
		var dir = (xAxis ? vel.v.x : vel.v.y) > 0 ? 1 : -1;
		for (sign in [1, -1]) {
			var nx = tr.pos.x, ny = tr.pos.y;
			if (xAxis) { nx += dir * NUDGE_PX; ny += sign * NUDGE_PX; }
			else       { ny += dir * NUDGE_PX; nx += sign * NUDGE_PX; }
			if (nx < 0 || nx > boundsW - col.w) continue;
			if (ny < 0 || ny > boundsH - col.h) continue;
			if (!overlapsAny(nx, ny, col, solids) && !overlapsAny(tr.pos.x, xAxis ? ny : tr.pos.y, col, solids)) {
				tr.pos.x = nx;
				tr.pos.y = ny;
				return;
			}
		}
	}

	static function overlapsAny(x:Float, y:Float, col:Collider, solids:Array<Entity>):Bool {
		for (s in solids) {
			var sTr = s.get(Transform);
			var sCol = s.get(Collider);
			if (AABB.overlapsRaw(x, y, col.w, col.h, sTr.pos.x, sTr.pos.y, sCol.w, sCol.h)) return true;
		}
		return false;
	}

	function solidsOf(world:World):Array<Entity> {
		var out = [];
		for (e in world.query(Collider)) if (e.get(Collider).solid && e.get(Transform) != null && !e.has(Velocity)) out.push(e);
		return out;
	}

	inline function clampX(tr:Transform, col:Collider):Void {
		if (tr.pos.x < 0)                 tr.pos.x = 0;
		if (tr.pos.x > boundsW - col.w)   tr.pos.x = boundsW - col.w;
	}

	inline function clampY(tr:Transform, col:Collider):Void {
		if (tr.pos.y < 0)                 tr.pos.y = 0;
		if (tr.pos.y > boundsH - col.h)   tr.pos.y = boundsH - col.h;
	}

	function resolveAxis(tr:Transform, col:Collider, solids:Array<Entity>, axisVel:Float, xAxis:Bool):Void {
		for (s in solids) {
			var sTr = s.get(Transform);
			var sCol = s.get(Collider);
			if (!AABB.overlapsRaw(tr.pos.x, tr.pos.y, col.w, col.h,
			                       sTr.pos.x, sTr.pos.y, sCol.w, sCol.h)) continue;
			if (xAxis) {
				tr.pos.x = axisVel > 0 ? sTr.pos.x - col.w : sTr.pos.x + sCol.w;
			} else {
				tr.pos.y = axisVel > 0 ? sTr.pos.y - col.h : sTr.pos.y + sCol.h;
			}
		}
	}
}
