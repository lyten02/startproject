package game.ui.hud;

import game.ecs.World;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;
import game.ui.mvp.IPresenter;

/** Reads world state each frame → populates HudModel → tells HudView to render. */
class HudPresenter implements IPresenter {
	public var model(default, null):HudModel;
	var view:HudView;
	var world:World;

	public function new(view:HudView, world:World, sceneLabel:String, hint:String) {
		this.view  = view;
		this.world = world;
		this.model = new HudModel();
		this.model.sceneLabel = sceneLabel;
		this.model.hint       = hint;
	}

	public function update(dt:Float):Void {
		model.fps = dt > 0 ? Math.round(1.0 / dt) : 0;

		var players = world.query(PlayerControlled);
		if (players.length > 0) {
			var tr = players[0].get(Transform);
			if (tr != null) {
				model.playerX = Std.int(tr.pos.x);
				model.playerY = Std.int(tr.pos.y);
			}
		}

		view.render(model);
	}

	public function dispose():Void {}
}
