package game.ecs.components;

/** 4-way facing direction (unit vector, one of (±1,0) or (0,±1)). */
class Facing implements Component {
	public var dx:Int;
	public var dy:Int;

	public function new(dx:Int = 0, dy:Int = 1) {
		this.dx = dx;
		this.dy = dy;
	}

	public inline function set(dx:Int, dy:Int):Void {
		this.dx = dx;
		this.dy = dy;
	}
}
