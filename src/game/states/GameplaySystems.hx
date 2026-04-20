package game.states;

import game.Game;
import game.ecs.World;
import game.map.MapData;
import game.core.Grid;
import game.systems.CollisionSystem;
import game.systems.InputSystem;
import game.systems.RenderSystem;
import game.systems.SpriteRenderSystem;

/**
 * Bundles every ECS system for the gameplay scene. Built once in `enter`;
 * `simulate` runs the world sim at scaled dt;
 * `render` draws visual systems at real dt.
 */
class GameplaySystems {
	var input:InputSystem;
	var collision:CollisionSystem;
	var renderS:RenderSystem;
	var sprite:SpriteRenderSystem;

	public function new(game:Game, worldLayer:h2d.Object, map:MapData, world:World) {
		input     = new InputSystem(game.input);
		collision = new CollisionSystem();
		collision.boundsW = Grid.cellToPx(map.width);
		collision.boundsH = Grid.cellToPx(map.height);
		renderS   = new RenderSystem(worldLayer);
		sprite    = new SpriteRenderSystem(worldLayer);
	}

	public inline function boundsW():Float return collision.boundsW;
	public inline function boundsH():Float return collision.boundsH;

	public function simulate(world:World, dt:Float, sdt:Float):Void {
		input.update(world, dt);
		collision.update(world, sdt);
	}

	public function renderAll(world:World, dt:Float):Void {
		renderS.update(world, dt);
		sprite.update(world, dt);
	}
}
