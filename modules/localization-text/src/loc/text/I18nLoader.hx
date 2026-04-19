package loc.text;

import loc.base.LocaleId;
import loc.base.KeyNamespace;

/**
 * Loads i18n JSON from res/i18n/<lang>/<namespace>.json and flattens nested
 * objects with dot-paths: {ui:{held:{ready:"..."}}} → ui.held.ready
 */
class I18nLoader {
	var store:I18nStore;

	public function new(store:I18nStore) this.store = store;

	public function loadLang(lang:LocaleId):Int {
		var count = 0;
		for (ns in KeyNamespace.ALL) count += loadNamespace(lang, ns);
		return count;
	}

	public function loadNamespace(lang:LocaleId, ns:KeyNamespace):Int {
		var path = "i18n/" + (lang : String) + "/" + (ns : String) + ".json";
		var raw = tryRead(path);
		if (raw == null) return 0;
		var parsed:Dynamic = try haxe.Json.parse(raw) catch (e:Dynamic) null;
		if (parsed == null) return 0;
		var flat = new Map<String, String>();
		flatten(parsed, (ns : String), flat);
		store.putAll(lang, flat);
		var n = 0;
		for (_ in flat.keys()) n++;
		return n;
	}

	function tryRead(resPath:String):Null<String> {
		#if (!nodejs)
		try {
			var r = hxd.Res.loader.load(resPath);
			return r.toText();
		} catch (e:Dynamic) {
			trace('[i18n] tryRead failed for "$resPath": $e');
			return null;
		}
		#else
		return null;
		#end
	}

	static function flatten(value:Dynamic, prefix:String, out:Map<String, String>):Void {
		if (value == null) return;
		if (Std.isOfType(value, String)) {
			out.set(prefix, value);
			return;
		}
		if (Reflect.isObject(value)) {
			for (f in Reflect.fields(value)) {
				flatten(Reflect.field(value, f), prefix + "." + f, out);
			}
		}
	}
}
