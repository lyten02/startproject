package loc.text;

import loc.base.I18nContract.PlaceholderArgs;

class PlaceholderFormatter {
	static final TOKEN = ~/\{(\w+)\}/g;

	public static function format(template:String, ?args:PlaceholderArgs):String {
		if (template == null) return "";
		if (args == null) return template;
		return TOKEN.map(template, function(r) {
			var name = r.matched(1);
			var v = args.get(name);
			return v == null ? r.matched(0) : v;
		});
	}

	public static function unresolvedPlaceholders(template:String, ?args:PlaceholderArgs):Array<String> {
		var out:Array<String> = [];
		if (template == null) return out;
		TOKEN.map(template, function(r) {
			var name = r.matched(1);
			if (args == null || args.get(name) == null) out.push(name);
			return r.matched(0);
		});
		return out;
	}
}
