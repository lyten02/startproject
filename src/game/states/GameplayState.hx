package game.states;

import game.Game;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;
import game.input.GameAction;
import game.map.EntityFactory;
import game.map.MapLoader;
import game.render.Camera;
import game.render.SceneScaler;
#if debug
import game.ui.debug.DebugPresenter;
import game.ui.debug.DebugView;
#end
import loc.text.font.FontRegistry;
import h2d.Object;

/**
 * Orchestrates gameplay: loads the map, owns camera + time-scale,
 * and delegates ECS systems to GameplaySystems.
 */
class GameplayState implements IGameState {
	static inline var MAP_PATH:String = "maps/level1.json";

	var game:Game;
	var root:Object;
	var worldLayer:Object;
	var world:World;
	var scaler:SceneScaler;
	var camera:Camera;
	var sys:GameplaySystems;

	#if debug
	var debugView:DebugView;
	var debugPresenter:DebugPresenter;
	var timeScale:game.core.TimeScale;
	var onS2dEvent:hxd.Event->Void;
	#end

	public function new(game:Game) {
		this.game = game;
	}

	public function enter():Void {
		root       = new Object(game.app.s2d);
		worldLayer = new Object(root);
		world      = new World();
		scaler     = new SceneScaler(1080);
		camera     = new Camera();

		var json = hxd.Res.load(MAP_PATH).toText();
		var map  = MapLoader.parse(json);
		EntityFactory.spawnAll(world, map);

		sys = new GameplaySystems(game, worldLayer, map, world);
		camera.worldW = sys.boundsW();
		camera.worldH = sys.boundsH();

		#if debug
		var debugFont = FontRegistry.get(18);
		debugView = new DebugView(debugFont, root);
		game.style.addObject(debugView);
		timeScale = new game.core.TimeScale();
		debugPresenter = new DebugPresenter(debugView, world, timeScale, camera);

		onS2dEvent = function(e:hxd.Event):Void {
			switch e.kind {
				case EWheel:
					camera.zoomBy(e.wheelDelta > 0 ? Camera.ZOOM_STEP : -Camera.ZOOM_STEP);
				case EPush if (e.button == 2):
					camera.resetZoom();
				default:
			}
		};
		game.app.s2d.addEventListener(onS2dEvent);
		#end
	}

	public function update(dt:Float):Void {
		scaler.sync(game.app.s2d.width, game.app.s2d.height);
		root.setScale(scaler.scale);

		var sdt = dt;
		#if debug
		if (timeScale != null) {
			if (game.input.wasPressed(GameAction.DebugSpeedUp))   timeScale.up();
			if (game.input.wasPressed(GameAction.DebugSpeedDown)) timeScale.down();
			sdt = dt * timeScale.value();
		}
		if (game.input.wasPressed(GameAction.DebugResetZoom)) camera.resetZoom();
		camera.tick(dt);
		#end

		sys.simulate(world, dt, sdt);

		var players = world.query(PlayerControlled);
		if (players.length > 0) {
			var tr = players[0].get(Transform);
			var col = players[0].get(Collider);
			var cx = tr.pos.x + (col != null ? col.w * 0.5 : 0);
			var cy = tr.pos.y + (col != null ? col.h * 0.5 : 0);
			camera.focus(cx, cy, scaler.vW, scaler.vH);
		}
		worldLayer.setScale(camera.zoom);
		worldLayer.x = -camera.x * camera.zoom;
		worldLayer.y = -camera.y * camera.zoom;

		sys.renderAll(world, dt);

		#if debug
		if (game.input.wasPressed(GameAction.ToggleDebug) && debugView != null) {
			debugView.visible = !debugView.visible;
		}
		if (debugView != null) {
			debugView.x = 8;
			debugView.y = 8;
			if (debugView.visible) debugPresenter.update(dt);
		}
		#end
	}

	public function exit():Void {
		#if debug
		if (debugView != null) game.style.removeObject(debugView);
		if (onS2dEvent != null) {
			game.app.s2d.removeEventListener(onS2dEvent);
			onS2dEvent = null;
		}
		#end
		if (root != null) { root.remove(); root = null; }
		world = null;
	}
}
