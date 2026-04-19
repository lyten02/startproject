package game.ui.title;

import game.ui.mvp.IPresenter;

class TitlePresenter implements IPresenter {
	public var model(default, null):TitleModel;
	var view:TitleView;

	public function new(view:TitleView, text:String) {
		this.view  = view;
		this.model = new TitleModel();
		this.model.text = text;
		view.render(model);
	}

	public function update(dt:Float):Void {
		// Static content → nothing to recompute. Caller re-renders on text change.
	}

	public function setText(t:String):Void {
		model.text = t;
		view.render(model);
	}

	public function dispose():Void {}
}
