package game.ui.actionbar;

import game.ecs.World;
import game.ecs.components.ActionFeedback;
import game.ecs.components.PlayerControlled;
import game.ui.mvp.IPresenter;
import loc.text.I18n;

/**
 * Reads the player's ActionFeedback each frame, decays ttl, maps to model.
 * Fade-out over the last FADE_SEC seconds of ttl; instantly visible when set.
 */
class ActionBarPresenter implements IPresenter {
	static inline var FADE_SEC:Float = 0.3;

	public var model(default, null):ActionBarModel;

	var view:ActionBarView;
	var world:World;

	public function new(view:ActionBarView, world:World) {
		this.view  = view;
		this.world = world;
		this.model = new ActionBarModel();
	}

	public function update(dt:Float):Void {
		var players = world.query(PlayerControlled);
		if (players.length == 0) { hide(); return; }
		var fb = players[0].get(ActionFeedback);
		if (fb == null || fb.ttl <= 0) { hide(); return; }

		fb.ttl -= dt;
		if (fb.ttl <= 0) { hide(); return; }

		model.visible = true;
		model.msg     = I18n.t(fb.msgKey, fb.msgArgs);
		model.color   = fb.color;
		model.alpha   = fb.ttl >= FADE_SEC ? 1 : (fb.ttl / FADE_SEC);
		view.render(model);
	}

	public function dispose():Void {}

	inline function hide():Void {
		model.visible = false;
		model.alpha   = 0;
		view.render(model);
	}
}
