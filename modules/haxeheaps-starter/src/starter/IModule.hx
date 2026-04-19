package starter;

/**
 * Interface for optional modules (gamepush, localization, etc.)
 * Modules are automatically discovered from the modules/ directory.
 *
 * Example:
 * ```haxe
 * class GamePushModule implements starter.IModule {
 *     public function new() {}
 *     public function init():Void { ... }
 *     public function update(dt:Float):Void { ... }
 *     public function dispose():Void { ... }
 * }
 * ```
 */
interface IModule {
	/**
	 * Initialize the module.
	 * Called after resources are loaded but before game.init().
	 */
	function init():Void;

	/**
	 * Whether this module requires async initialization.
	 * If true, initAsync() will be called instead of init().
	 * Default: false
	 */
	var requiresAsync(get, never):Bool;

	/**
	 * Initialize the module asynchronously.
	 * Called only if requiresAsync returns true.
	 * @param callback Call with true on success, false on failure.
	 */
	function initAsync(callback:Bool->Void):Void;

	/**
	 * Update module logic every frame.
	 * Called before game.update().
	 * @param dt Delta time in seconds since last frame.
	 */
	function update(dt:Float):Void;

	/**
	 * Clean up module resources.
	 * Called after game.dispose() but before application exits.
	 */
	function dispose():Void;
}
