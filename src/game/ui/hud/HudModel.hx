package game.ui.hud;

/** Plain data the HudView renders. Reset by HudPresenter each frame. */
class HudModel {
	public var sceneLabel:String = "";
	public var hint:String       = "";
	public var fps:Int           = 0;
	public var playerX:Int       = 0;
	public var playerY:Int       = 0;

	public function new() {}
}
