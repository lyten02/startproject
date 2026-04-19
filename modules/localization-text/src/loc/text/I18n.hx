package loc.text;

import loc.base.LocaleId;
import loc.base.LocEvent;
import loc.base.I18nContract.PlaceholderArgs;

class I18n {
	public static var signal(default, null):I18nSignal = new I18nSignal();

	static var store:I18nStore = new I18nStore();
	static var loader:I18nLoader = new I18nLoader(store);
	static var missing:MissingKeyLogger = new MissingKeyLogger();
	static var currentLang:LocaleId = LocaleId.EN;
	static var baseLang:LocaleId = LocaleId.EN;
	static var initialized:Bool = false;

	public static function init(?base:LocaleId):Void {
		if (base != null) baseLang = base;
		currentLang = baseLang;
		loader.loadLang(baseLang);
		initialized = true;
		signal.dispatch(Loaded(baseLang));
	}

	public static function setLanguage(lang:LocaleId):Void {
		if (!initialized) init(baseLang);
		if (store.countOf(lang) == 0 && lang != baseLang) {
			loader.loadLang(lang);
			signal.dispatch(Loaded(lang));
		}
		if ((lang : String) == (currentLang : String)) return;
		currentLang = lang;
		signal.dispatch(Change(lang));
	}

	public static inline function current():LocaleId return currentLang;

	public static inline function base():LocaleId return baseLang;

	public static function t(key:String, ?args:PlaceholderArgs):String {
		if (!initialized) return "#" + key;
		var raw = store.resolve(key, currentLang);
		if (raw == null && (currentLang : String) != (baseLang : String)) {
			missing.report(key, currentLang);
			signal.dispatch(MissingKey(key, currentLang));
			raw = store.resolve(key, baseLang);
		}
		if (raw == null) {
			missing.report(key, baseLang);
			return "#" + key;
		}
		return PlaceholderFormatter.format(raw, args);
	}

	public static inline function has(key:String):Bool return store.has(key, currentLang);

	public static inline function flushMissing():Void missing.flushIfOverflow();

	public static inline function store_():I18nStore return store;

	public static inline function missing_():MissingKeyLogger return missing;

	/**
	 * Seed the store with a pre-flattened key→value map for a language.
	 * Intended for tests or runtime overrides that bypass hxd.Res.
	 */
	public static function feedFlat(lang:LocaleId, entries:Map<String, String>):Void {
		if (!initialized) {
			baseLang = lang;
			currentLang = lang;
			initialized = true;
		}
		store.putAll(lang, entries);
	}

	/** Reset the singleton (tests only). */
	public static function resetForTests():Void {
		store = new I18nStore();
		loader = new I18nLoader(store);
		missing.reset();
		currentLang = LocaleId.EN;
		baseLang = LocaleId.EN;
		initialized = false;
	}
}
