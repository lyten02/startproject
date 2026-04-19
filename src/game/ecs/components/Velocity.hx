package game.ecs.components;

import game.core.Vec2;

/** Per-frame desired displacement (px/sec). */
class Velocity implements Component {
	public var v:Vec2;

	public function new() {
		this.v = new Vec2(0, 0);
	}
}
