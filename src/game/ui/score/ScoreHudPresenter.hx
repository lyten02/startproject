package game.ui.score;

import game.ecs.World;
import game.ecs.components.GameStats;
import game.ui.mvp.IPresenter;

/**
 * Reads the singleton GameStats each frame and pushes the snapshot to the
 * view. No mutation — mutators live in OrderDeliverySystem / OrderPatienceSystem.
 */
class ScoreHudPresenter implements IPresenter {
	public var model(default, null):ScoreHudModel;

	var view:ScoreHudView;
	var world:World;

	public function new(view:ScoreHudView, world:World) {
		this.view  = view;
		this.world = world;
		this.model = new ScoreHudModel();
	}

	public function update(_:Float):Void {
		var all = world.query(GameStats);
		if (all.length == 0) return;
		var s = all[0].get(GameStats);
		model.served = s.served;
		model.failed = s.failed;
		model.money  = s.money;
		view.render(model);
	}

	public function dispose():Void {}
}
