package loc.base;

typedef PlaceholderArgs = haxe.DynamicAccess<String>;

typedef I18nContract = {
	function t(key:String, ?args:PlaceholderArgs):String;
	function setLanguage(id:LocaleId):Void;
	function current():LocaleId;
}
