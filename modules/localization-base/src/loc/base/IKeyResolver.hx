package loc.base;

interface IKeyResolver {
	function resolve(key:String, lang:LocaleId):Null<String>;
	function has(key:String, lang:LocaleId):Bool;
}
