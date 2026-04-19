package loc.base;

enum LocEvent {
	Change(lang:LocaleId);
	Loaded(lang:LocaleId);
	MissingKey(key:String, lang:LocaleId);
}
