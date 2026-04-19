package starter;

/**
 * Interface for games using the starter framework.
 * Implement this interface in your Game class.
 *
 * Example:
 * ```haxe
 * class MyGame implements starter.IGame {
 *     public function new() {}
 *     public function init(app:hxd.App):Void { ... }
 *     public function update(dt:Float):Void { ... }
 *     public function dispose():Void { ... }
 * }
 * ```
 */
interface IGame {
	/**
	 * Initialize the game. Called after App.init() and resource loading.
	 * @param app The hxd.App instance for accessing s2d, s3d, etc.
	 */
	function init(app:hxd.App):Void;

	/**
	 * Update game logic every frame.
	 * @param dt Delta time in seconds since last frame.
	 */
	function update(dt:Float):Void;

	/**
	 * Clean up resources when the game is closing.
	 * Called before the application exits.
	 */
	function dispose():Void;
}
