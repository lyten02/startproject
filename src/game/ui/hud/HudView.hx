package game.ui.hud;

import game.ui.mvp.IView;

/** Domkit component + IView. Renders HudModel, no game logic. */
@:uiComp("hud-view")
class HudView extends h2d.Flow implements h2d.domkit.Object implements IView<HudModel> {
	static var SRC = <hud-view>
		<text public id="titleText" class="title" text={""}/>
		<text public id="hintText"  class="hint"  text={""}/>
		<text public id="statsText" class="badge" text={""}/>
	</hud-view>;

	public function new(titleFont:h2d.Font, bodyFont:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		titleText.font = titleFont; titleText.smooth = true;
		hintText.font  = bodyFont;  hintText.smooth  = true;
		statsText.font = bodyFont;  statsText.smooth = true;
	}

	public function render(m:HudModel):Void {
		titleText.text = m.sceneLabel;
		hintText.text  = m.hint;
		statsText.text = 'FPS: ${m.fps}   x: ${m.playerX}  y: ${m.playerY}';
	}
}
