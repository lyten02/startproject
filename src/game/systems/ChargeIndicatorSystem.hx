package game.systems;

import game.core.Grid;
import game.core.ThrowPhysics;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Facing;
import game.ecs.components.Hands;
import game.ecs.components.Transform;
import h2d.Graphics;

/**
 * Per-frame charge gauge for hold-to-throw.
 *
 * Rendered opposite to the player's facing so the held item stays visible:
 *   facing up    → bar below player
 *   facing down  → bar above player
 *   facing right → bar to the left
 *   facing left  → bar to the right
 *
 * Fill color is interpolated across a gradient (green → yellow → red) and
 * the fill width is proportional to chargeSec / MAX_CHARGE, clamped.
 * Hidden while not charging.
 */
class ChargeIndicatorSystem implements ISystem {
	static inline var BAR_W:Float   = 64;
	static inline var BAR_H:Float   = 8;
	static inline var GAP:Float     = 6;      // distance from player AABB edge
	static inline var SEGMENTS:Int  = 24;
	static inline var BG_COLOR:Int  = 0x000000;
	static inline var BG_ALPHA:Float = 0.55;
	static inline var BORDER:Int    = 0xFFFFFF;

	var root:h2d.Object;
	var g:Graphics;

	public function new(root:h2d.Object) {
		this.root = root;
	}

	public function update(world:World, dt:Float):Void {
		var players = world.query(Hands);
		if (players.length == 0) { hide(); return; }
		var p = players[0];
		var hands = p.get(Hands);
		// Hide during the tap window — only show once the press has passed the
		// throw threshold so quick pickup/place taps don't flash the bar.
		if (!hands.charging || hands.held == null || hands.chargeSec < ThrowPhysics.MIN_CHARGE) {
			hide();
			return;
		}

		ensure();
		g.visible = true;
		g.clear();

		// Remap [MIN_CHARGE..MAX_CHARGE] → [0..1] so the bar starts empty at the
		// threshold and fills fully at the max-speed point.
		var span = ThrowPhysics.MAX_CHARGE - ThrowPhysics.MIN_CHARGE;
		var ratio = span > 0 ? (hands.chargeSec - ThrowPhysics.MIN_CHARGE) / span : 0;
		if (ratio < 0) ratio = 0;
		else if (ratio > 1) ratio = 1;

		var anchor = anchorFor(p);
		drawBar(anchor.x, anchor.y, anchor.horizontal, ratio);
	}

	function ensure():Void {
		if (g == null) g = new Graphics(root);
	}

	function hide():Void {
		if (g != null) { g.clear(); g.visible = false; }
	}

	function anchorFor(player:game.ecs.Entity):{x:Float, y:Float, horizontal:Bool} {
		var tr = player.get(Transform);
		var co = player.get(Collider);
		var fc = player.get(Facing);
		var cx = tr.pos.x + co.w * 0.5;
		var cy = tr.pos.y + co.h * 0.5;

		// Opposite to facing — bar sits behind the player.
		if (fc.dy < 0) { // facing up → bar below
			return { x: cx - BAR_W * 0.5, y: tr.pos.y + co.h + GAP, horizontal: true };
		}
		if (fc.dy > 0) { // facing down → bar above
			return { x: cx - BAR_W * 0.5, y: tr.pos.y - GAP - BAR_H, horizontal: true };
		}
		if (fc.dx > 0) { // facing right → bar to left (vertical)
			return { x: tr.pos.x - GAP - BAR_H, y: cy - BAR_W * 0.5, horizontal: false };
		}
		// facing left → bar to right (vertical)
		return { x: tr.pos.x + co.w + GAP, y: cy - BAR_W * 0.5, horizontal: false };
	}

	function drawBar(x:Float, y:Float, horizontal:Bool, ratio:Float):Void {
		var w = horizontal ? BAR_W : BAR_H;
		var h = horizontal ? BAR_H : BAR_W;

		// Translucent backdrop + 1 px border.
		g.beginFill(BG_COLOR, BG_ALPHA);
		g.drawRect(x, y, w, h);
		g.endFill();

		// Segmented fill — simulates a gradient by tinting each slice independently.
		var along = horizontal ? BAR_W : BAR_W; // fill runs along the long axis
		var segW  = along / SEGMENTS;
		var filled = Math.round(SEGMENTS * ratio);
		for (i in 0...filled) {
			var t = (i + 0.5) / SEGMENTS;
			var col = gradient(t);
			g.beginFill(col, 1);
			if (horizontal) {
				g.drawRect(x + i * segW, y, segW + 0.5, BAR_H);
			} else {
				// Vertical bar fills bottom-up so low charge is near the player.
				g.drawRect(x, y + (SEGMENTS - 1 - i) * segW, BAR_H, segW + 0.5);
			}
			g.endFill();
		}

		g.lineStyle(1, BORDER, 0.9);
		g.drawRect(x, y, w, h);
	}

	/**
	 * t ∈ [0, 1]. 0.0 = green, 0.5 = yellow, 1.0 = red.
	 * Piecewise linear interp in RGB — good enough for a HUD gauge.
	 */
	static function gradient(t:Float):Int {
		if (t < 0) t = 0; else if (t > 1) t = 1;
		var r:Float, g:Float, b:Float = 0x40;
		if (t < 0.5) {
			var u = t * 2;           // green → yellow
			r = 0x40 + u * (0xFF - 0x40);
			g = 0xCC;
			b = 0x40;
		} else {
			var u = (t - 0.5) * 2;   // yellow → red
			r = 0xFF;
			g = 0xCC - u * (0xCC - 0x30);
			b = 0x30;
		}
		return (Std.int(r) << 16) | (Std.int(g) << 8) | Std.int(b);
	}
}
