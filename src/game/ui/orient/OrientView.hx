package game.ui.orient;

import game.ui.mvp.IView;

@:uiComp("orient-view")
class OrientView extends h2d.Flow implements h2d.domkit.Object implements IView<OrientModel> {
	static var SRC = <orient-view>
		<text public id="mainText" class="orient-main" text={""}/>
		<text public id="subText"  class="orient-sub"  text={""}/>
	</orient-view>;

	public function new(big:h2d.Font, sub:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		mainText.font = big; mainText.smooth = true;
		subText.font  = sub; subText.smooth  = true;
	}

	public function render(m:OrientModel):Void {
		mainText.text = m.main;
		subText.text  = m.sub;
	}
}
