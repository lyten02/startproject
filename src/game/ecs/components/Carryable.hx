package game.ecs.components;

import game.ecs.Entity;

/** Marker: this entity can be picked up. `heldBy` is null while resting. */
class Carryable implements Component {
	public var heldBy:Entity;

	public function new() {}
}
