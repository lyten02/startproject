package game.core;

/** Mutable 2D vector. Pure data + math, no engine deps (testable). */
class Vec2 {
	public var x:Float;
	public var y:Float;

	public inline function new(x:Float = 0, y:Float = 0) {
		this.x = x;
		this.y = y;
	}

	public inline function set(x:Float, y:Float):Vec2 {
		this.x = x;
		this.y = y;
		return this;
	}

	public inline function copyFrom(other:Vec2):Vec2 {
		this.x = other.x;
		this.y = other.y;
		return this;
	}

	public inline function add(dx:Float, dy:Float):Vec2 {
		this.x += dx;
		this.y += dy;
		return this;
	}

	public inline function clone():Vec2 return new Vec2(x, y);

	public inline function equals(other:Vec2):Bool return x == other.x && y == other.y;
}
