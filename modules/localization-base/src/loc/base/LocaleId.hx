package loc.base;

abstract LocaleId(String) from String to String {
	public static inline final EN:LocaleId = "en";
	public static inline final RU:LocaleId = "ru";
	public static inline final TR:LocaleId = "tr";
	public static inline final DE:LocaleId = "de";
	public static inline final ZH:LocaleId = "zh";

	public static final ALL:Array<LocaleId> = [EN, RU, TR, DE, ZH];

	public inline function new(v:String) this = v;

	public inline function toString():String return this;

	public static function parse(raw:String):LocaleId {
		var lower = raw == null ? "" : raw.toLowerCase();
		for (id in ALL) if ((id : String) == lower) return id;
		return EN;
	}
}
