package game.ui.held;

import game.ui.mvp.IView;

/** Bottom-left panel: what's currently in the player's hands. */
@:uiComp("held-item")
class HeldItemView extends h2d.Flow implements h2d.domkit.Object implements IView<HeldItemModel> {
	static var SRC = <held-item>
		<text public id="titleText" class="title" text={""}/>
		<text public id="bodyText"  class="body"  text={""}/>
	</held-item>;

	public function new(font:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		titleText.font = font; titleText.smooth = true;
		bodyText.font  = font; bodyText.smooth  = true;
	}

	public function render(m:HeldItemModel):Void {
		this.visible = m.visible;
		if (!this.visible) return;
		titleText.text      = m.title;
		titleText.textColor = m.tint;
		bodyText.text       = m.body;
		bodyText.textColor  = m.bodyColor;
	}
}
