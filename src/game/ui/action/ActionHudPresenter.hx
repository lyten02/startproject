package game.ui.action;

import game.ecs.World;
import game.ecs.components.Hands;
import game.ecs.components.PlayerControlled;
import game.ui.mvp.IPresenter;

/** Each frame computes available player actions and pushes them into the View. */
class ActionHudPresenter implements IPresenter {
	public var model(default, null):ActionHudModel;

	var view:ActionHudView;
	var world:World;
	var resolver:ActionHintResolver;

	public function new(view:ActionHudView, world:World) {
		this.view     = view;
		this.world    = world;
		this.resolver = new ActionHintResolver();
		this.model    = new ActionHudModel();
	}

	public function update(dt:Float):Void {
		var players = world.query(PlayerControlled);
		if (players.length == 0) { hide(); return; }
		var hands = players[0].get(Hands);
		if (hands == null)        { hide(); return; }

		model.hints   = resolver.resolve(world, players[0], hands);
		model.visible = model.hints.length > 0;
		view.render(model);
	}

	public function dispose():Void {}

	inline function hide():Void {
		model.hints   = [];
		model.visible = false;
		view.render(model);
	}
}
