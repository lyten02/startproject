package loc.text.reactive;

import h2d.Font;
import h2d.Object;
import h2d.Text;
import loc.base.I18nContract.PlaceholderArgs;
import loc.base.LocEvent;
import loc.text.I18n;

/**
 * Text node tied to an i18n key. Subscribes to I18n.signal and refreshes on
 * language change / load. Auto-unsubscribes in onRemove (no leaks on state swap).
 */
class ReactiveText extends Text {
	var key:String;
	var args:PlaceholderArgs;
	var unlisten:Void->Void;

	public function new(font:Font, key:String, ?args:PlaceholderArgs, ?parent:Object) {
		super(font, parent);
		this.key = key;
		this.args = args;
		refresh();
		unlisten = I18n.signal.listen(onEvent);
	}

	public function setKey(key:String, ?args:PlaceholderArgs):Void {
		this.key = key;
		this.args = args;
		refresh();
	}

	public function setArgs(args:PlaceholderArgs):Void {
		this.args = args;
		refresh();
	}

	function onEvent(e:LocEvent):Void {
		switch e {
			case Change(_), Loaded(_): refresh();
			case MissingKey(_, _):
		}
	}

	inline function refresh():Void {
		this.text = I18n.t(key, args);
	}

	override function onRemove():Void {
		if (unlisten != null) { unlisten(); unlisten = null; }
		super.onRemove();
	}
}
