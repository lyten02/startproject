package game.systems;

import game.core.Grid;
import game.core.ThrowPhysics;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Facing;
import game.ecs.components.Hands;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;
import h2d.Graphics;

/**
 * Debug-only trajectory preview.
 *
 * While the player is charging a throw (Hands.charging && held), simulates
 * the full flight with current charge speed — substep + bounce + stall, same
 * as ThrowSystem — and draws:
 *   - a polyline along sampled positions (fading green → yellow → red);
 *   - a ringed marker on the predicted resting cell;
 *   - a red ring if the trajectory terminates inside a Trash trigger.
 *
 * Each frame recomputes from scratch so the preview follows the charge bar.
 */
class ThrowPreviewSystem implements ISystem {
	static inline var SIM_DT:Float    = 1 / 60;
	static inline var MAX_STEPS:Int   = 600;
	static inline var LINE_COLOR:Int  = 0x33FFFF;
	static inline var LAND_COLOR:Int  = 0xFFFF66;
	static inline var TABLE_COLOR:Int = 0x66AAFF;
	static inline var TRASH_COLOR:Int = 0xFF3030;
	static inline var KICK_COLOR:Int  = 0xFF8833;

	var root:h2d.Object;
	var g:Graphics;

	public function new(root:h2d.Object) {
		this.root = root;
	}

	public function update(world:World, dt:Float):Void {
		var players = world.query(Hands);
		if (players.length == 0) { hide(); return; }
		var player = players[0];
		var hands = player.get(Hands);
		// Suppress while the press is still in tap territory — avoids flashing
		// a trajectory for pickups / placements that never become throws.
		if (!hands.charging || hands.held == null || hands.chargeSec < ThrowPhysics.MIN_CHARGE) {
			hide();
			return;
		}

		if (g == null) g = new Graphics(root);
		g.visible = true;
		g.clear();

		var fc = player.get(Facing);
		var ptr = player.get(Transform);
		var pc  = player.get(Collider);
		var ic  = hands.held.get(Collider);
		if (fc == null || ptr == null || pc == null || ic == null) return;

		var pcx = Math.floor((ptr.pos.x + pc.w * 0.5) / Grid.CELL);
		var pcy = Math.floor((ptr.pos.y + pc.h * 0.5) / Grid.CELL);
		var x = pcx * Grid.CELL + (Grid.CELL - ic.w) * 0.5;
		var y = pcy * Grid.CELL + (Grid.CELL - ic.h) * 0.5;

		var speed = ThrowPhysics.chargeToSpeed(hands.chargeSec);
		var vx = fc.dx * speed, vy = fc.dy * speed;
		var vz = ThrowPhysics.LAUNCH_VZ;
		var z = 1.0;
		var bounces = 0;

		drawDot(x + ic.w * 0.5, y + ic.h * 0.5);
		var outcome = "land";
		for (i in 0...MAX_STEPS) {
			var projX = x + vx * SIM_DT;
			var projY = y + vy * SIM_DT;

			if (ThrowSystem.overlapsTrash(world, projX, projY, ic.w, ic.h)) {
				x = projX; y = projY; outcome = "trash"; break;
			}
			if (ThrowSystem.findRestingCarryable(world, hands.held, projX, projY, ic.w, ic.h) != null) {
				x = projX; y = projY; outcome = "kick"; break;
			}

			if (ThrowSystem.collidesSolid(world, hands.held, projX, y, ic.w, ic.h)) {
				vx = ThrowPhysics.bounce(vx); bounces++;
			} else {
				x = projX;
			}
			var nextY = y + vy * SIM_DT;
			if (ThrowSystem.collidesSolid(world, hands.held, x, nextY, ic.w, ic.h)) {
				vy = ThrowPhysics.bounce(vy); bounces++;
			} else {
				y = nextY;
			}

			z  += vz * SIM_DT;
			vz -= ThrowPhysics.GRAVITY * SIM_DT;

			drawDot(x + ic.w * 0.5, y + ic.h * 0.5);

			var stalled = vx * vx + vy * vy < ThrowPhysics.STALL_SPEED * ThrowPhysics.STALL_SPEED;
			if (ThrowPhysics.hasLanded(z, vz) || bounces >= ThrowPhysics.MAX_BOUNCES || stalled) break;
		}
		// If plain landing lands on a Surface cell, highlight as table placement.
		if (outcome == "land") {
			var cx = Math.floor((x + ic.w * 0.5) / Grid.CELL);
			var cy = Math.floor((y + ic.h * 0.5) / Grid.CELL);
			if (InteractQueries.findSurfaceAtCell(world, cx, cy) != null) outcome = "table";
		}
		drawMarker(x, y, ic.w, ic.h, outcome);
	}

	public function hide():Void {
		if (g != null) { g.clear(); g.visible = false; }
	}

	inline function drawDot(cx:Float, cy:Float):Void {
		g.beginFill(LINE_COLOR, 0.55);
		g.drawRect(cx - 1.5, cy - 1.5, 3, 3);
		g.endFill();
	}

	function drawMarker(x:Float, y:Float, w:Float, h:Float, outcome:String):Void {
		var cellX = Math.floor((x + w * 0.5) / Grid.CELL) * Grid.CELL;
		var cellY = Math.floor((y + h * 0.5) / Grid.CELL) * Grid.CELL;
		var color = switch outcome {
			case "trash": TRASH_COLOR;
			case "kick":  KICK_COLOR;
			case "table": TABLE_COLOR;
			default:      LAND_COLOR;
		};
		g.beginFill(color, 0.22);
		g.drawRect(cellX, cellY, Grid.CELL, Grid.CELL);
		g.endFill();
		g.lineStyle(2, color, 0.95);
		g.drawRect(cellX, cellY, Grid.CELL, Grid.CELL);
	}
}
