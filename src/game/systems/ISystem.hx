package game.systems;

import game.ecs.World;

/** Frame processor: reads/writes components on a World. */
interface ISystem {
	function update(world:World, dt:Float):Void;
}
