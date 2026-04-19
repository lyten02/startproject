package game.ui.title;

import game.ui.mvp.IView;

@:uiComp("title-view")
class TitleView extends h2d.Flow implements h2d.domkit.Object implements IView<TitleModel> {
	static var SRC = <title-view>
		<text public id="label" class="scene-title" text={""}/>
	</title-view>;

	public function new(font:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		label.font   = font;
		label.smooth = true;
	}

	public function render(m:TitleModel):Void {
		label.text = m.text;
	}
}
