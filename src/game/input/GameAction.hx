package game.input;

/**
 * All logical input actions used by the game. Strongly typed — `dn.heaps.input.Controller`
 * uses this abstract enum via `createFromAbstractEnum` to generate bindings at compile time.
 */
enum abstract GameAction(Int) to Int {
	var MoveLeft;
	var MoveRight;
	var MoveUp;
	var MoveDown;
	var ToggleDebug;
	var Pause;
	var Cookbook;
	var Interact;
	var DebugStateRaw;
	var DebugStateChopped;
	var DebugStateCooked;
	var DebugStateBurnt;
	var DebugStateSpoiled;
	var DebugStateBoiled;
	var DebugToggleDirty;
	var DebugSpeedUp;
	var DebugSpeedDown;
	var DebugResetZoom;
	var DebugSpawnDish;
}
