package game.ecs.components;

/** Tag: receives input → Velocity. */
class PlayerControlled implements Component {
	public var speed:Float;

	public function new(speed:Float = 200) {
		this.speed = speed;
	}
}
