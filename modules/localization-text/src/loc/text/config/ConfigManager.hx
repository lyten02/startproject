package loc.text.config;

/**
 * Load/save of the localization config. Order of precedence:
 *   1. localStorage (runtime overrides — written by save()).
 *   2. res/config/localization.json (baked defaults, read via hxd.Res).
 *   3. ConfigMigrator.defaults() (emergency fallback).
 *
 * save() snapshots the previous stored value into a timestamped backup before
 * overwriting — no data loss from schema migrations or user edits.
 */
class ConfigManager {
	public static function load():ConfigSchema {
		var stored = readStored();
		trace('[i18n] readStored (localStorage) = ${stored == null ? "null" : haxe.Json.stringify(stored)}');
		var raw = stored;
		if (raw == null) {
			raw = readDefaultJson();
			trace('[i18n] readDefaultJson (res) = ${raw == null ? "null" : haxe.Json.stringify(raw)}');
		}
		if (raw == null) { trace('[i18n] no config source → defaults'); return ConfigMigrator.defaults(); }
		var obj:Dynamic = try haxe.Json.parse(raw) catch (e:Dynamic) null;
		if (obj == null) { trace('[i18n] JSON parse failed → defaults, raw was: $raw'); return ConfigMigrator.defaults(); }
		return ConfigMigrator.migrate(obj);
	}

	public static function save(cfg:ConfigSchema):Void {
		#if (js && !nodejs)
		if (js.Browser.supported) {
			var ls = js.Browser.window.localStorage;
			var previous = ls.getItem(ConfigBackup.STORAGE_KEY);
			if (previous != null) ConfigBackup.snapshot(previous);
			ls.setItem(ConfigBackup.STORAGE_KEY, haxe.Json.stringify(cfg));
		}
		#end
	}

	static function readStored():Null<String> {
		#if (js && !nodejs)
		if (js.Browser.supported) {
			return js.Browser.window.localStorage.getItem(ConfigBackup.STORAGE_KEY);
		}
		#end
		return null;
	}

	static function readDefaultJson():Null<String> {
		#if (js && !nodejs)
		// Bypass hxd.Res caching + browser HTTP cache by fetching synchronously
		// with a cache-busting timestamp. Ensures config edits take effect on
		// reload without hitting a stale XHR cache.
		try {
			var xhr = new js.html.XMLHttpRequest();
			xhr.open("GET", "res/config/localization.json?_=" + Std.string(Date.now().getTime()), false);
			xhr.send();
			if (xhr.status >= 200 && xhr.status < 300) return xhr.responseText;
		} catch (e:Dynamic) {}
		#end
		#if (!nodejs)
		try {
			return hxd.Res.loader.load("config/localization.json").toText();
		} catch (e:Dynamic) {}
		#end
		return null;
	}
}
