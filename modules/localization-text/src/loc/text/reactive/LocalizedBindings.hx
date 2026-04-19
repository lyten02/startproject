package loc.text.reactive;

import loc.base.I18nContract.PlaceholderArgs;
import loc.base.LocEvent;
import loc.text.I18n;

typedef ITextTarget = { var text:String; };

/**
 * Binds any `{ text:String }` target (h2d.Text, Domkit text node, string
 * holder) to an i18n key. Returns a disposer — call it to stop receiving
 * updates. Presenter holds disposers and frees them on dispose() to respect
 * MVP rule F (no h2d import inside Presenters).
 */
class LocalizedBindings {
	public static function bindTextKey(target:ITextTarget, key:String, ?args:PlaceholderArgs):Void->Void {
		var curKey = key;
		var curArgs = args;
		function apply() target.text = I18n.t(curKey, curArgs);
		apply();
		var unlisten = I18n.signal.listen(function(e:LocEvent) {
			switch e {
				case Change(_), Loaded(_): apply();
				case MissingKey(_, _):
			}
		});
		return unlisten;
	}

	public static function bindComputed(target:ITextTarget, compute:Void->String):Void->Void {
		function apply() target.text = compute();
		apply();
		var unlisten = I18n.signal.listen(function(e:LocEvent) {
			switch e {
				case Change(_), Loaded(_): apply();
				case MissingKey(_, _):
			}
		});
		return unlisten;
	}
}
