package game.states;

/**
 * Minimal state machine contract — enter/update/exit lifecycle.
 * Each state owns its own scene content and cleans it up on exit.
 */
interface IGameState {
	function enter():Void;
	function update(dt:Float):Void;
	function exit():Void;
}
