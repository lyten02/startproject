package loc.text;

import loc.base.LocaleId;

class MissingKeyLogger {
	public static final FLUSH_THRESHOLD:Int = 20;

	var buffer:Map<String, Array<String>> = new Map();

	public function new() {}

	public function report(key:String, lang:LocaleId):Void {
		var langStr = (lang : String);
		var arr = buffer.get(langStr);
		if (arr == null) {
			arr = [];
			buffer.set(langStr, arr);
		}
		if (arr.indexOf(key) == -1) {
			arr.push(key);
			trace('[i18n] missing: ${langStr}.${key}');
		}
	}

	public function flushIfOverflow():Void {
		for (lang => keys in buffer) {
			if (keys.length >= FLUSH_THRESHOLD) {
				trace('[i18n] [${lang}] ${keys.length} missing keys (compile-time macro writes logs/i18n-missing-${lang}-<ts>.log)');
				buffer.set(lang, []);
			}
		}
	}

	public function snapshot():Map<String, Array<String>> {
		var copy = new Map<String, Array<String>>();
		for (k => v in buffer) copy.set(k, v.copy());
		return copy;
	}

	public function reset():Void buffer = new Map();
}
