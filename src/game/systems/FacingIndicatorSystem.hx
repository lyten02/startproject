package game.systems;

import game.core.Grid;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Facing;
import game.ecs.components.Transform;
import h2d.Graphics;

/**
 * Per frame draws:
 *   - a small triangle arrow inside the player's AABB pointing in Facing dir
 *   - a translucent 32×32 highlight on the grid cell directly in front of the player
 *
 * Attached to the world layer (scrolls with camera). The highlight marks the cell
 * that future interaction code will target.
 */
class FacingIndicatorSystem implements ISystem {
	static inline var HIGHLIGHT_COLOR:Int = 0xFFFF66;
	static inline var HIGHLIGHT_ALPHA:Float = 0.35;
	static inline var ARROW_COLOR:Int = 0xFFFFFF;
	static inline var ARROW_SIZE:Float = 10;

	var root:h2d.Object;
	var arrow:Graphics;
	var highlight:Graphics;

	public function new(root:h2d.Object) {
		this.root = root;
	}

	public function update(world:World, dt:Float):Void {
		var players = world.query(Facing);
		if (players.length == 0) {
			if (arrow != null) arrow.visible = false;
			if (highlight != null) highlight.visible = false;
			return;
		}

		var e  = players[0];
		var tr = e.get(Transform);
		var fc = e.get(Facing);
		if (tr == null || fc == null) return;

		var col = e.get(Collider);
		var w = col != null ? col.w : Grid.CELL;
		var h = col != null ? col.h : Grid.CELL;

		ensureArrow();
		ensureHighlight();

		// Arrow — triangle centered on the facing edge of the player box.
		var cx = tr.pos.x + w * 0.5;
		var cy = tr.pos.y + h * 0.5;
		var tipX = cx + fc.dx * (w * 0.5);
		var tipY = cy + fc.dy * (h * 0.5);
		drawArrow(tipX, tipY, fc.dx, fc.dy);

		// Highlight — grid cell directly in front of the player.
		var playerCellX = Std.int((tr.pos.x + w * 0.5) / Grid.CELL);
		var playerCellY = Std.int((tr.pos.y + h * 0.5) / Grid.CELL);
		var targetX = (playerCellX + fc.dx) * Grid.CELL;
		var targetY = (playerCellY + fc.dy) * Grid.CELL;
		highlight.x = targetX;
		highlight.y = targetY;
		highlight.visible = true;
	}

	function ensureArrow():Void {
		if (arrow != null) return;
		arrow = new Graphics(root);
	}

	function ensureHighlight():Void {
		if (highlight != null) return;
		highlight = new Graphics(root);
		highlight.beginFill(HIGHLIGHT_COLOR, HIGHLIGHT_ALPHA);
		highlight.drawRect(0, 0, Grid.CELL, Grid.CELL);
		highlight.endFill();
		highlight.lineStyle(2, HIGHLIGHT_COLOR, 0.9);
		highlight.drawRect(0, 0, Grid.CELL, Grid.CELL);
	}

	function drawArrow(tipX:Float, tipY:Float, dx:Int, dy:Int):Void {
		arrow.clear();
		arrow.beginFill(ARROW_COLOR, 1);
		// Triangle with apex at (tipX, tipY), base perpendicular to facing.
		var s = ARROW_SIZE;
		var bx = tipX - dx * s;
		var by = tipY - dy * s;
		// Perpendicular offset (rotate facing 90°).
		var px = -dy * s * 0.5;
		var py =  dx * s * 0.5;
		arrow.moveTo(tipX, tipY);
		arrow.lineTo(bx + px, by + py);
		arrow.lineTo(bx - px, by - py);
		arrow.endFill();
		arrow.visible = true;
	}
}
