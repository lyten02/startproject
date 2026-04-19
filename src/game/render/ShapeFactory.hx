package game.render;

import game.ecs.components.ShapeRender.ShapeKind;
import h2d.Graphics;
import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;

/**
 * Builds h2d objects from ShapeKind enum.
 *
 * Convention: every shape is drawn in top-left-origin space, i.e. the shape's
 * bounding box sits at (0, 0) → (w, h). Transform.pos is then the bbox top-left
 * — consistent with Rect, AABB colliders, grid coordinates.
 */
class ShapeFactory {
	public static inline var OUTLINE_W:Float = 2;

	public static function build(kind:ShapeKind, color:Int, parent:Object):Object {
		return switch kind {
			case Rect(w, h)        : rect(w, h, color, parent);
			case Circle(r)         : poly(c -> c.drawCircle(r, r, r), color, parent);
			case Triangle(hw, hh)  : poly(c -> triPath(c, hw * 2, hh * 2), color, parent);
			case Diamond(hw, hh)   : poly(c -> diamondPath(c, hw * 2, hh * 2), color, parent);
			case Hexagon(r)        : poly(c -> hexPath(c, r), color, parent);
		}
	}

	static inline function rect(w:Float, h:Float, color:Int, parent:Object):Bitmap {
		return new Bitmap(Tile.fromColor(color, Std.int(w), Std.int(h)), parent);
	}

	static inline function poly(draw:(Graphics)->Void, color:Int, parent:Object):Graphics {
		var g = new Graphics(parent);
		g.lineStyle(OUTLINE_W, color);
		g.beginFill(color);
		draw(g);
		g.endFill();
		return g;
	}

	static function triPath(c:Graphics, w:Float, h:Float):Void {
		c.moveTo(w * 0.5, 0);
		c.lineTo(w, h);
		c.lineTo(0, h);
		c.lineTo(w * 0.5, 0);
	}

	static function diamondPath(c:Graphics, w:Float, h:Float):Void {
		c.moveTo(w * 0.5, 0);
		c.lineTo(w, h * 0.5);
		c.lineTo(w * 0.5, h);
		c.lineTo(0, h * 0.5);
		c.lineTo(w * 0.5, 0);
	}

	static function hexPath(c:Graphics, r:Float):Void {
		// Bbox (0,0)→(2r, 2r·sin60°·2) — use diameter, center hex inside.
		var cx = r;
		var cy = r;
		for (i in 0...7) {
			var a = i * Math.PI / 3.0;
			var px = cx + Math.cos(a) * r;
			var py = cy + Math.sin(a) * r;
			if (i == 0) c.moveTo(px, py) else c.lineTo(px, py);
		}
	}
}
