package loc.text;

import loc.base.LocaleId;
import loc.base.IKeyResolver;

class I18nStore implements IKeyResolver {
	var data:Map<String, Map<String, String>> = new Map();

	public function new() {}

	public function put(lang:LocaleId, key:String, value:String):Void {
		bucket(lang).set(key, value);
	}

	public function putAll(lang:LocaleId, entries:Map<String, String>):Void {
		var b = bucket(lang);
		for (k => v in entries) b.set(k, v);
	}

	public function resolve(key:String, lang:LocaleId):Null<String> {
		var b = data.get(lang);
		return b == null ? null : b.get(key);
	}

	public function has(key:String, lang:LocaleId):Bool {
		var b = data.get(lang);
		return b != null && b.exists(key);
	}

	public function keysOf(lang:LocaleId):Iterator<String> {
		var b = data.get(lang);
		return b == null ? [].iterator() : b.keys();
	}

	public function countOf(lang:LocaleId):Int {
		var b = data.get(lang);
		if (b == null) return 0;
		var n = 0;
		for (_ in b.keys()) n++;
		return n;
	}

	public function missing(lang:LocaleId, base:LocaleId):Array<String> {
		var baseBucket = data.get(base);
		if (baseBucket == null) return [];
		var b = data.get(lang);
		var out:Array<String> = [];
		for (k in baseBucket.keys()) {
			if (b == null || !b.exists(k)) out.push(k);
		}
		return out;
	}

	public function clear(lang:LocaleId):Void {
		data.remove(lang);
	}

	function bucket(lang:LocaleId):Map<String, String> {
		var b = data.get(lang);
		if (b == null) {
			b = new Map();
			data.set(lang, b);
		}
		return b;
	}
}
