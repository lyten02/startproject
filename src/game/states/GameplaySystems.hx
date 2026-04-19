package game.states;

import game.Game;
import game.ecs.World;
import game.ecs.components.GameStats;
import game.ecs.components.OrderQueue;
import game.map.MapData;
import game.core.Grid;
import game.orders.OrderConfig;
import game.systems.CarryFollowSystem;
import game.systems.ChargeIndicatorSystem;
import game.systems.CollisionSystem;
import game.systems.CookingSystem;
import game.systems.FacingIndicatorSystem;
import game.systems.InputSystem;
import game.systems.IngredientInspectorSystem;
import game.systems.IngredientStateSystem;
import game.systems.InteractSystem;
import game.systems.LabelSystem;
import game.systems.OrderDeliverySystem;
import game.systems.OrderPatienceSystem;
import game.systems.OrderSpawnSystem;
import game.systems.PlateSpriteSyncSystem;
import game.systems.PlateStackRenderSystem;
import game.systems.RenderSystem;
import game.systems.SpriteRenderSystem;
import game.systems.PlateStackLayoutSystem;
import game.systems.SinkQueueSystem;
import game.systems.ThrowSystem;

/**
 * Bundles every ECS system for the gameplay scene. Built once in `enter`;
 * `simulate` runs the world sim at scaled dt (skipped when paused);
 * `render` draws visual systems at real dt regardless of pause.
 */
class GameplaySystems {
	public var interact(default, null):InteractSystem;

	var input:InputSystem;
	var collision:CollisionSystem;
	var renderS:RenderSystem;
	var sprite:SpriteRenderSystem;
	var plateStack:PlateStackRenderSystem;
	var plateSync:PlateSpriteSyncSystem;
	var facing:FacingIndicatorSystem;
	var charge:ChargeIndicatorSystem;
	var label:LabelSystem;
	var inspector:IngredientInspectorSystem;
	var ingState:IngredientStateSystem;
	var cooking:CookingSystem;
	var sinkQueue:SinkQueueSystem;
	var stackLayout:PlateStackLayoutSystem;
	var carry:CarryFollowSystem;
	var throwS:ThrowSystem;
	var orderSpawn:OrderSpawnSystem;
	var orderPatience:OrderPatienceSystem;
	var orderDelivery:OrderDeliverySystem;

	public function new(game:Game, worldLayer:h2d.Object, map:MapData, bodyFont:h2d.Font, world:World, orderConfig:OrderConfig) {
		input     = new InputSystem(game.input);
		collision = new CollisionSystem();
		collision.boundsW = Grid.cellToPx(map.width);
		collision.boundsH = Grid.cellToPx(map.height);
		renderS   = new RenderSystem(worldLayer);
		sprite    = new SpriteRenderSystem(worldLayer);
		plateStack = new PlateStackRenderSystem(worldLayer);
		plateSync  = new PlateSpriteSyncSystem();
		facing    = new FacingIndicatorSystem(worldLayer);
		interact  = new InteractSystem(game.input);
		carry     = new CarryFollowSystem();
		throwS    = new ThrowSystem();
		throwS.worldW = collision.boundsW;
		throwS.worldH = collision.boundsH;
		charge    = new ChargeIndicatorSystem(worldLayer);
		label     = new LabelSystem(worldLayer, bodyFont);
		inspector = new IngredientInspectorSystem(worldLayer, bodyFont);
		ingState  = new IngredientStateSystem(game.input);
		cooking   = new CookingSystem(worldLayer, game.input);
		sinkQueue = new SinkQueueSystem();
		stackLayout = new PlateStackLayoutSystem();
		orderSpawn    = new OrderSpawnSystem(orderConfig);
		orderPatience = new OrderPatienceSystem();
		orderDelivery = new OrderDeliverySystem();
		world.create().add(new OrderQueue(orderConfig.maxQueueSize));
		world.create().add(new GameStats());
	}

	public inline function boundsW():Float return collision.boundsW;
	public inline function boundsH():Float return collision.boundsH;

	public function simulate(world:World, dt:Float, sdt:Float):Void {
		input.update(world, dt);
		collision.update(world, sdt);
		interact.update(world, dt);
		ingState.update(world, sdt);
		cooking.update(world, sdt);
		sinkQueue.update(world, sdt);
		stackLayout.update(world, sdt);
		throwS.update(world, sdt);
		carry.update(world, sdt);
		orderSpawn.update(world, sdt);
		orderPatience.update(world, sdt);
		orderDelivery.update(world, sdt);
	}

	public function renderAll(world:World, dt:Float):Void {
		renderS.update(world, dt);
		plateSync.update(world, dt);
		sprite.update(world, dt);
		plateStack.update(world, dt);
		facing.update(world, dt);
		charge.update(world, dt);
		label.update(world, dt);
		inspector.update(world, dt);
	}
}
