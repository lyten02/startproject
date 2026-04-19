package loc.text.config;

/**
 * Takes a snapshot of the current stored config before overwrite. Web builds
 * write into localStorage under "...backup.YYYY-MM-DD-HHMMSS". Non-JS targets
 * (tests) skip the snapshot — caller treats failures as non-fatal.
 */
class ConfigBackup {
	public static inline var STORAGE_KEY = "overcooked.localization";
	public static inline var BACKUP_PREFIX = "overcooked.localization.backup.";

	public static function snapshot(rawJson:String):Void {
		#if (js && !nodejs)
		if (js.Browser.supported) {
			var stamp = timestamp();
			js.Browser.window.localStorage.setItem(BACKUP_PREFIX + stamp, rawJson);
		}
		#end
	}

	static function timestamp():String {
		return DateTools.format(Date.now(), "%Y-%m-%d-%H%M%S");
	}
}
