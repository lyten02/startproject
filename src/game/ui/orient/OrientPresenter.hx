package game.ui.orient;

import game.ui.mvp.IPresenter;
import loc.base.LocEvent;
import loc.text.I18n;

/**
 * Subscribes to I18n so the device-rotation overlay stays in the current
 * language. Text is resolved by key on every Change/Loaded event.
 */
class OrientPresenter implements IPresenter {
	public var model(default, null):OrientModel;

	var view:OrientView;
	var mainKey:String;
	var subKey:String;
	var unlisten:Void->Void;

	public function new(view:OrientView, mainKey:String, subKey:String) {
		this.view    = view;
		this.mainKey = mainKey;
		this.subKey  = subKey;
		this.model   = new OrientModel();
		refresh();
		unlisten = I18n.signal.listen(onLocEvent);
	}

	public function update(dt:Float):Void {}

	public function dispose():Void {
		if (unlisten != null) { unlisten(); unlisten = null; }
	}

	function onLocEvent(e:LocEvent):Void {
		switch e {
			case Change(_), Loaded(_): refresh();
			case MissingKey(_, _):
		}
	}

	function refresh():Void {
		model.main = I18n.t(mainKey);
		model.sub  = I18n.t(subKey);
		view.render(model);
	}
}
