package game.systems;

import game.ecs.World;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Velocity;
import game.input.InputBindings;

/** Reads InputBindings, writes Velocity on PlayerControlled entities. */
class InputSystem implements ISystem {
	var input:InputBindings;

	public function new(input:InputBindings) {
		this.input = input;
	}

	public function update(world:World, dt:Float):Void {
		var dx = input.moveX();
		var dy = input.moveY();
		for (e in world.query(PlayerControlled)) {
			var pc  = e.get(PlayerControlled);
			var vel = e.get(Velocity);
			if (vel == null) continue;
			vel.v.set(dx * pc.speed, dy * pc.speed);
		}
	}
}
