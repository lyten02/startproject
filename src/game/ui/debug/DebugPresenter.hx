package game.ui.debug;

import game.core.TimeScale;
import game.ecs.World;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;
import game.render.Camera;
import game.ui.mvp.IPresenter;

/** Populates DebugModel from live state. Startup ms is frozen on first update. */
class DebugPresenter implements IPresenter {
	static inline var CELL:Float = 32;

	public var model(default, null):DebugModel;
	var view:DebugView;
	var world:World;
	var timeScale:TimeScale;
	var camera:Camera;
	var startStamp:Float;
	var firstFrameStamp:Float = 0;
	var fpsAccumDt:Float = 0;
	var fpsAccumFrames:Int = 0;
	var fpsAccumLast:Float = 0;

	public function new(view:DebugView, world:World, ?timeScale:TimeScale, ?camera:Camera) {
		this.view      = view;
		this.world     = world;
		this.timeScale = timeScale;
		this.camera    = camera;
		this.model     = new DebugModel();
		this.startStamp = haxe.Timer.stamp();
	}

	public function update(dt:Float):Void {
		var now = haxe.Timer.stamp();

		if (firstFrameStamp == 0) {
			firstFrameStamp = now;
			var boot = (firstFrameStamp - Main.startupStamp) * 1000;
			model.startupMs = Std.int(boot);
		}

		model.frameMs = dt * 1000;
		fpsAccumDt     += dt;
		fpsAccumFrames += 1;
		if (fpsAccumDt - fpsAccumLast >= 0.5) {
			model.fps = fpsAccumDt > 0 ? Math.round(fpsAccumFrames / fpsAccumDt) : 0;
			fpsAccumLast   = fpsAccumDt;
			fpsAccumFrames = 0;
			fpsAccumDt     = 0;
		}

		model.entities = world.count();
		model.uptimeSec = Std.int(now - startStamp);

		var players = world.query(PlayerControlled);
		if (players.length > 0) {
			var tr = players[0].get(Transform);
			if (tr != null) {
				var px = Std.int(tr.pos.x);
				var py = Std.int(tr.pos.y);
				model.playerPx = '$px,$py';
				model.playerCell = '${Std.int(tr.pos.x / CELL)},${Std.int(tr.pos.y / CELL)}';
			}
		}

		model.heapMB = readHeapMB();

		// CPU% = share of the 60-fps frame budget actually spent in JS.
		var budgetMs = 1000 / 60;
		var pct = model.frameMs / budgetMs * 100;
		if (pct < 0) pct = 0; else if (pct > 100) pct = 100;
		model.cpuPct = Std.int(pct);

		// GPU-work proxy via the currently-bound Heaps engine.
		var eng = h3d.Engine.getCurrent();
		if (eng != null) {
			model.drawCalls = Std.int(eng.drawCalls);
			model.triangles = Std.int(eng.drawTriangles);
		}

		if (timeScale != null) model.speed = timeScale.label();
		#if debug
		if (camera != null) model.zoom = (Math.round(camera.zoom * 100) / 100) + "x";
		#end

		view.render(model);
	}

	public function dispose():Void {}

	static function readHeapMB():String {
		#if js
		var perf:Dynamic = js.Browser.window.performance;
		if (perf != null && perf.memory != null) {
			var used:Float = perf.memory.usedJSHeapSize;
			var total:Float = perf.memory.totalJSHeapSize;
			return '${Std.int(used / 1048576)}/${Std.int(total / 1048576)}MB';
		}
		return "n/a";
		#else
		return "n/a";
		#end
	}
}
