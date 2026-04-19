package game.ui.mvp;

/** Presenter updates its model from game state, then pushes to its view. */
interface IPresenter {
	function update(dt:Float):Void;
	function dispose():Void;
}
