package game.systems;

import game.core.Grid;
import game.core.ThrowPhysics;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.InFlight;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Surface;
import game.ecs.components.Transform;
import game.ecs.components.Trash;

/**
 * Flat-throw integrator with elastic-bounce collision response.
 *
 * Per frame each InFlight item:
 *   - checks its projected AABB against Trash triggers (destroy on overlap);
 *   - substeps X then Y independently: if the next step overlaps a solid
 *     collider, the corresponding velocity component reflects with
 *     RESTITUTION loss and `bounces++`; otherwise the position advances;
 *   - applies vertical gravity to z (for the scale-pop visual only);
 *   - lands (and snaps to a grid cell) when z returns to floor, bounces hit
 *     MAX_BOUNCES, or the XY speed falls below STALL_SPEED.
 */
class ThrowSystem implements ISystem {
	public var worldW:Float = 0;
	public var worldH:Float = 0;

	public function new() {}

	public function update(world:World, dt:Float):Void {
		for (e in world.query(InFlight)) {
			var f  = e.get(InFlight);
			var tr = e.get(Transform);
			var co = e.get(Collider);
			if (tr == null || co == null) continue;

			// Trash trigger test — destroy before any bounce logic.
			var projX = tr.pos.x + f.vx * dt;
			var projY = tr.pos.y + f.vy * dt;
			if (overlapsTrash(world, projX, projY, co.w, co.h)) {
				EntityDestroyer.destroy(world, e);
				continue;
			}

			// Kick-on-contact: flying item hits a resting plate → transfer momentum.
			var hit = findRestingCarryable(world, e, projX, projY, co.w, co.h);
			if (hit != null) {
				kickResting(world, hit, f);
				land(world, e, tr, co, f, tr.pos.x, tr.pos.y);
				continue;
			}

			// Substep X independently → reflect vx on wall, advance otherwise.
			if (collidesSolid(world, e, projX, tr.pos.y, co.w, co.h)) {
				f.vx = ThrowPhysics.bounce(f.vx);
				f.bounces++;
			} else {
				tr.pos.x = projX;
			}

			// Substep Y after X resolution.
			var nextY = tr.pos.y + f.vy * dt;
			if (collidesSolid(world, e, tr.pos.x, nextY, co.w, co.h)) {
				f.vy = ThrowPhysics.bounce(f.vy);
				f.bounces++;
			} else {
				tr.pos.y = nextY;
			}

			// Vertical arc only affects render scale (flat-throw model).
			f.z  += f.vz * dt;
			f.vz -= ThrowPhysics.GRAVITY * dt;

			var speed2 = f.vx * f.vx + f.vy * f.vy;
			var stalled = speed2 < ThrowPhysics.STALL_SPEED * ThrowPhysics.STALL_SPEED;
			if (ThrowPhysics.hasLanded(f.z, f.vz) || f.bounces >= ThrowPhysics.MAX_BOUNCES || stalled) {
				land(world, e, tr, co, f, tr.pos.x, tr.pos.y);
			}
		}
	}

	function land(world:World, e:Entity, tr:Transform, co:Collider, f:InFlight, x:Float, y:Float):Void {
		var c = ThrowPhysics.clampToBounds(x, y, co.w, co.h, worldW, worldH);
		var cx = Math.floor((c.x + co.w * 0.5) / Grid.CELL);
		var cy = Math.floor((c.y + co.h * 0.5) / Grid.CELL);

		// If the landing cell belongs to a Surface and its slot is free,
		// register the item as the occupant — identical to manual placement.
		var surf = InteractQueries.findSurfaceAtCell(world, cx, cy);
		if (surf != null) {
			var sc = surf.get(Surface);
			if (sc.occupantAt(cx, cy) == null) {
				sc.place(cx, cy, e);
			} else {
				var slot = InteractQueries.freeSlotNear(surf, sc, cx, cy);
				if (slot != null) { cx = slot.cx; cy = slot.cy; sc.place(cx, cy, e); }
			}
		}
		tr.pos.x = cx * Grid.CELL + (Grid.CELL - co.w) * 0.5;
		tr.pos.y = cy * Grid.CELL + (Grid.CELL - co.h) * 0.5;
		f.z = 0;
		e.remove(InFlight);
	}

	public static function findRestingCarryable(world:World, self:Entity, x:Float, y:Float, w:Float, h:Float):Entity {
		var r = x + w, b = y + h;
		for (other in world.query(Carryable)) {
			if (other == self) continue;
			var car = other.get(Carryable);
			if (car.heldBy != null) continue;
			if (other.has(InFlight)) continue;
			var oc = other.get(Collider);
			var otr = other.get(Transform);
			if (oc == null || otr == null) continue;
			var or = otr.pos.x + oc.w, ob = otr.pos.y + oc.h;
			if (x < or && r > otr.pos.x && y < ob && b > otr.pos.y) return other;
		}
		return null;
	}

	static function kickResting(world:World, hit:Entity, f:InFlight):Void {
		// Transfer KICK_FACTOR of horizontal speed, give a small vertical pop.
		hit.add(new InFlight(
			f.vx * ThrowPhysics.KICK_FACTOR,
			f.vy * ThrowPhysics.KICK_FACTOR,
			ThrowPhysics.KICK_LAUNCH_VZ,
			1
		));
		// If the plate was sitting on a Surface slot, free it.
		for (s in world.query(Surface)) {
			var sc = s.get(Surface);
			var at = sc.cellOf(hit);
			if (at != null) sc.clear(at.cx, at.cy);
		}
	}

	public static function overlapsTrash(world:World, x:Float, y:Float, w:Float, h:Float):Bool {
		var r = x + w, b = y + h;
		for (t in world.query(Trash)) {
			var oc = t.get(Collider);
			var otr = t.get(Transform);
			if (oc == null || otr == null) continue;
			var or = otr.pos.x + oc.w, ob = otr.pos.y + oc.h;
			if (x < or && r > otr.pos.x && y < ob && b > otr.pos.y) return true;
		}
		return false;
	}

	public static function collidesSolid(world:World, self:Entity, x:Float, y:Float, w:Float, h:Float):Bool {
		var r = x + w, b = y + h;
		for (other in world.query(Collider)) {
			if (other == self) continue;
			if (other.has(PlayerControlled)) continue;
			if (other.has(Trash)) continue;   // Trash uses the trigger path, not bounce.
			if (other.has(Surface)) continue; // Fly OVER tables; landing handler registers us.
			var oc = other.get(Collider);
			if (!oc.solid) continue;
			var otr = other.get(Transform);
			if (otr == null) continue;
			var or = otr.pos.x + oc.w, ob = otr.pos.y + oc.h;
			if (x < or && r > otr.pos.x && y < ob && b > otr.pos.y) return true;
		}
		return false;
	}
}
