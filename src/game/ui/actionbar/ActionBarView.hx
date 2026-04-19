package game.ui.actionbar;

import game.ui.mvp.IView;

/**
 * Centered transient status line (below crosshair). Single text element,
 * driven purely by ActionBarModel. No game logic, no world access.
 */
@:uiComp("action-bar")
class ActionBarView extends h2d.Flow implements h2d.domkit.Object implements IView<ActionBarModel> {
	static var SRC = <action-bar>
		<text public id="msgText" class="msg" text={""}/>
	</action-bar>;

	public function new(font:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		msgText.font   = font;
		msgText.smooth = true;
	}

	public function render(m:ActionBarModel):Void {
		this.visible = m.visible && m.alpha > 0.01;
		if (!this.visible) return;
		msgText.text      = m.msg;
		msgText.textColor = m.color;
		this.alpha        = m.alpha;
	}
}
