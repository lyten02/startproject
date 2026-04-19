package game.core;

/**
 * Axis-aligned bounding box with top-left origin. Pure, testable.
 * Used by Collider component and CollisionSystem.
 */
class AABB {
	public var x:Float;
	public var y:Float;
	public var w:Float;
	public var h:Float;

	public inline function new(x:Float = 0, y:Float = 0, w:Float = 0, h:Float = 0) {
		this.x = x;
		this.y = y;
		this.w = w;
		this.h = h;
	}

	public inline function right():Float return x + w;
	public inline function bottom():Float return y + h;

	/** True when this box overlaps `other`. */
	public inline function overlaps(other:AABB):Bool {
		return x < other.x + other.w && x + w > other.x
		    && y < other.y + other.h && y + h > other.y;
	}

	/** Static variant for raw coords (avoids allocation in hot loops). */
	public static inline function overlapsRaw(ax:Float, ay:Float, aw:Float, ah:Float,
	                                           bx:Float, by:Float, bw:Float, bh:Float):Bool {
		return ax < bx + bw && ax + aw > bx
		    && ay < by + bh && ay + ah > by;
	}
}
