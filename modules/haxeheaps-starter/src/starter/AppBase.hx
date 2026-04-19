package starter;

import hxd.App;

/**
 * Base application class for the starter framework.
 * Manages game lifecycle and modules.
 *
 * Usage:
 * ```haxe
 * import starter.AppBase;
 * import game.MyGame;
 *
 * class Main extends AppBase {
 *     override function createGame():starter.IGame {
 *         return new MyGame();
 *     }
 *
 *     static function main() {
 *         new Main();
 *     }
 * }
 * ```
 */
class AppBase extends App {
	var game:IGame;
	var modules:Array<IModule> = [];
	var pauseTokens:haxe.ds.StringMap<Bool> = new haxe.ds.StringMap();

	/**
	 * Create the game instance. Override in subclass.
	 * @return IGame instance or null if no game.
	 */
	function createGame():IGame {
		return null;
	}

	/**
	 * Register a module to be managed by the app.
	 * Call this in initModules() to add custom modules.
	 */
	function registerModule(module:IModule):Void {
		modules.push(module);
	}

	/**
	 * Initialize modules. Override to add custom modules.
	 * Called after resources are loaded but before game.init().
	 */
	function initModules():Void {
		#if gamepush
		trace("GamePush module enabled");
		// Example: registerModule(new gamepush.GamePushModule());
		#end
	}

	var initStartTime:Float;

	override function init() {
		initStartTime = haxe.Timer.stamp();

		// 1. Initialize resources
		var resStartTime = haxe.Timer.stamp();
		hxd.Res.initEmbed();
		var resTime = haxe.Timer.stamp() - resStartTime;
		trace('Resources loaded in ${Std.int(resTime * 1000)}ms');

		// 2. Initialize modules (sync first, then async)
		initModules();
		initModulesSequential(0);
	}

	function initModulesSequential(index:Int):Void {
		if (index >= modules.length) {
			// All modules initialized, start game
			startGame();
			return;
		}

		var module = modules[index];
		if (module.requiresAsync) {
			module.initAsync(function(success) {
				if (!success) {
					trace('[AppBase] Module async init failed, continuing...');
				}
				initModulesSequential(index + 1);
			});
		} else {
			module.init();
			initModulesSequential(index + 1);
		}
	}

	public function startGame():Void {
		// 3. Create and initialize game
		game = createGame();
		if (game != null) {
			game.init(this);
		}

		// Auto-focus canvas for keyboard input (JS only)
		#if js
		var canvas = js.Browser.document.getElementById("webgl");
		if (canvas != null) {
			canvas.setAttribute("tabindex", "0");
			// Focus on click on canvas only (not form elements)
			js.Browser.document.addEventListener("click", function(e:js.html.Event) {
				// Check both click target and currently focused element
				var target:js.html.Element = cast e.target;
				var active:js.html.Element = cast js.Browser.document.activeElement;

				// Don't steal focus from form elements
				var targetTag = target.tagName.toUpperCase();
				var activeTag = active != null ? active.tagName.toUpperCase() : "";

				if (targetTag == "INPUT" || targetTag == "TEXTAREA" || targetTag == "SELECT" || targetTag == "BUTTON") {
					return;
				}
				if (activeTag == "INPUT" || activeTag == "TEXTAREA" || activeTag == "SELECT") {
					return;
				}
				canvas.focus();
			});
			// Initial focus with small delay to let Heaps initialize
			js.Browser.window.setTimeout(function() {
				canvas.focus();
			}, 100);
		}
		#end

		var totalTime = haxe.Timer.stamp() - initStartTime;
		trace('=== Total init time: ${Std.int(totalTime * 1000)}ms ===');
	}

	/**
	 * Set or clear a named pause token.
	 * When at least one token is active, update loop is suspended.
	 */
	public function setPauseToken(token:String, paused:Bool):Void {
		if (paused)
			pauseTokens.set(token, true);
		else
			pauseTokens.remove(token);
	}

	/**
	 * True when update loop is currently suspended.
	 */
	public function isUpdatePaused():Bool {
		return pauseTokens.iterator().hasNext();
	}

	override function update(dt:Float) {
		if (isUpdatePaused())
			return;

		// Update modules first
		for (module in modules) {
			module.update(dt);
		}

		// Update game
		if (game != null) {
			game.update(dt);
		}
	}

	override function dispose() {
		// Dispose game first
		if (game != null) {
			game.dispose();
		}

		// Dispose modules
		for (module in modules) {
			module.dispose();
		}

		super.dispose();
	}
}
