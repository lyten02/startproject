package game.ecs.components;

import game.core.Vec2;

/** World-space position (top-left). */
class Transform implements Component {
	public var pos:Vec2;

	public function new(x:Float = 0, y:Float = 0) {
		this.pos = new Vec2(x, y);
	}
}
