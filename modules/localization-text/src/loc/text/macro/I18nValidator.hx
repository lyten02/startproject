#if macro
package loc.text.macro;

import haxe.macro.Context;
import sys.io.File;
import sys.FileSystem;

/**
 * Compile-time i18n validator. Invoked via `--macro loc.text.macro.I18nValidator.scan()`.
 *
 * Reads `res/i18n/en/*.json` as the baseline, then for each non-base language
 * collects all missing keys. <= FLUSH_THRESHOLD missing keys → inline warnings
 * (printed by `haxe --no-output`); > threshold → written to
 * `logs/i18n-missing-<lang>-<timestamp>.log` plus a one-line summary warning.
 * Fully translated → silent.
 */
class I18nValidator {
	static inline var BASE_LANG = "en";
	static final OTHER_LANGS:Array<String> = ["ru", "tr", "de", "zh"];
	static final NAMESPACES:Array<String>  = ["ui", "actions", "recipes", "ingredients", "messages"];
	static inline var FLUSH_THRESHOLD = 20;

	public static function scan():Void {
		var root = normalize(Sys.getCwd());
		var i18nDir = root + "res/i18n/";
		var baseDir = i18nDir + BASE_LANG;
		if (!FileSystem.exists(baseDir)) {
			Context.warning("[i18n] baseline not found: " + baseDir, Context.currentPos());
			return;
		}
		var baseKeys = collectKeys(baseDir);
		var logsDir  = root + "logs/";
		var timestamp = DateTools.format(Date.now(), "%Y-%m-%d-%H%M%S");

		for (lang in OTHER_LANGS) {
			var dir = i18nDir + lang;
			var langKeys = FileSystem.exists(dir) ? collectKeys(dir) : new Map<String, Bool>();
			var missing:Array<String> = [];
			for (k in baseKeys.keys()) if (!langKeys.exists(k)) missing.push(k);
			missing.sort(Reflect.compare);
			if (missing.length == 0) continue;

			if (missing.length > FLUSH_THRESHOLD) {
				if (!FileSystem.exists(logsDir)) FileSystem.createDirectory(logsDir);
				var logPath = logsDir + "i18n-missing-" + lang + "-" + timestamp + ".log";
				var body = '# i18n missing keys — lang=$lang, generated=$timestamp\n'
					+ '# baseline keys: ${countKeys(baseKeys)}, missing: ${missing.length}\n'
					+ missing.join("\n") + "\n";
				File.saveContent(logPath, body);
				Context.warning('[i18n] $lang: ${missing.length} missing keys — see $logPath',
					Context.currentPos());
			} else {
				for (k in missing) {
					Context.warning('[i18n] missing: $lang.$k', Context.currentPos());
				}
			}
		}
	}

	static function collectKeys(dir:String):Map<String, Bool> {
		var out = new Map<String, Bool>();
		for (ns in NAMESPACES) {
			var path = dir + "/" + ns + ".json";
			if (!FileSystem.exists(path)) continue;
			var raw = try File.getContent(path) catch (e:Dynamic) null;
			if (raw == null) continue;
			var parsed:Dynamic = try haxe.Json.parse(raw) catch (e:Dynamic) null;
			if (parsed == null) continue;
			flatten(parsed, ns, out);
		}
		return out;
	}

	static function flatten(value:Dynamic, prefix:String, out:Map<String, Bool>):Void {
		if (value == null) return;
		if (Std.isOfType(value, String)) {
			out.set(prefix, true);
			return;
		}
		if (Reflect.isObject(value)) {
			for (f in Reflect.fields(value)) {
				flatten(Reflect.field(value, f), prefix + "." + f, out);
			}
		}
	}

	static function countKeys(m:Map<String, Bool>):Int {
		var n = 0;
		for (_ in m.keys()) n++;
		return n;
	}

	static inline function normalize(p:String):String {
		var r = StringTools.replace(p, "\\", "/");
		return StringTools.endsWith(r, "/") ? r : r + "/";
	}
}
#end
