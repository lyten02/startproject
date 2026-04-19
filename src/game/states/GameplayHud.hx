package game.states;

import game.Game;
import game.ecs.World;
import game.render.SceneScaler;
import game.ui.action.ActionHudPresenter;
import game.ui.action.ActionHudView;
import game.ui.actionbar.ActionBarPresenter;
import game.ui.actionbar.ActionBarView;
import game.ui.held.HeldItemPresenter;
import game.ui.held.HeldItemView;
import game.ui.orders.OrderQueuePresenter;
import game.ui.orders.OrderQueueView;
import game.ui.score.ScoreHudPresenter;
import game.ui.score.ScoreHudView;

/**
 * Owns the screen-space MVP stack for gameplay: context action HUD,
 * transient action bar, and held-item panel. Handles build/update/teardown +
 * re-positioning against the current virtual viewport.
 */
class GameplayHud {
	var game:Game;

	var actionHudView:ActionHudView;
	var actionHudPresenter:ActionHudPresenter;
	var actionBarView:ActionBarView;
	var actionBarPresenter:ActionBarPresenter;
	var heldView:HeldItemView;
	var heldPresenter:HeldItemPresenter;
	var orderQueueView:OrderQueueView;
	var orderQueuePresenter:OrderQueuePresenter;
	var scoreView:ScoreHudView;
	var scorePresenter:ScoreHudPresenter;
	var pauseOverlay:PauseOverlay;
	var cookbookOverlay:CookbookOverlay;

	public function new(game:Game, world:World, root:h2d.Object, bodyFont:h2d.Font) {
		this.game = game;
		this.pauseOverlay = new PauseOverlay(root, bodyFont);
		this.cookbookOverlay = new CookbookOverlay(root, bodyFont);

		actionHudView = new ActionHudView(bodyFont, root);
		game.style.addObject(actionHudView);
		actionHudPresenter = new ActionHudPresenter(actionHudView, world);

		actionBarView = new ActionBarView(bodyFont, root);
		game.style.addObject(actionBarView);
		actionBarPresenter = new ActionBarPresenter(actionBarView, world);

		heldView = new HeldItemView(bodyFont, root);
		game.style.addObject(heldView);
		heldPresenter = new HeldItemPresenter(heldView, world);

		orderQueueView = new OrderQueueView(bodyFont, root);
		game.style.addObject(orderQueueView);
		orderQueuePresenter = new OrderQueuePresenter(orderQueueView, world);

		scoreView = new ScoreHudView(bodyFont, root);
		game.style.addObject(scoreView);
		scorePresenter = new ScoreHudPresenter(scoreView, world);
	}

	public function update(dt:Float, scaler:SceneScaler):Void {
		actionHudPresenter.update(dt);
		actionHudView.x = scaler.vW - actionHudView.outerWidth - 24;
		actionHudView.y = scaler.vH - actionHudView.outerHeight - 24;

		actionBarPresenter.update(dt);
		actionBarView.x = (scaler.vW - actionBarView.outerWidth) * 0.5;
		actionBarView.y = scaler.vH * 0.625;

		heldPresenter.update(dt);
		heldView.x = 24;
		heldView.y = scaler.vH - heldView.outerHeight - 24;

		orderQueuePresenter.update(dt);
		orderQueueView.x = (scaler.vW - orderQueueView.outerWidth) * 0.5;
		orderQueueView.y = 24;

		scorePresenter.update(dt);
		scoreView.x = scaler.vW - scoreView.outerWidth - 24;
		scoreView.y = 24;

		pauseOverlay.position(scaler);
		cookbookOverlay.position(scaler);
	}

	public function setPaused(paused:Bool):Void {
		pauseOverlay.visible = paused;
	}

	public function setCookbookVisible(v:Bool):Void {
		cookbookOverlay.visible = v;
	}

	public function isCookbookVisible():Bool {
		return cookbookOverlay.visible;
	}

	public function dispose():Void {
		if (actionHudView != null) game.style.removeObject(actionHudView);
		if (actionBarView != null) game.style.removeObject(actionBarView);
		if (heldView != null)      game.style.removeObject(heldView);
		if (orderQueueView != null) game.style.removeObject(orderQueueView);
		if (scoreView != null) game.style.removeObject(scoreView);
		if (pauseOverlay != null)    pauseOverlay.dispose();
		if (cookbookOverlay != null) cookbookOverlay.dispose();
	}
}
