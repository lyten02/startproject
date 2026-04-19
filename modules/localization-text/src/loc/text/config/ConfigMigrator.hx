package loc.text.config;

/**
 * Migrates an unknown-version config payload to the current ConfigSchema.
 * Old versions get their fields coerced / defaulted; unknown fields dropped.
 */
class ConfigMigrator {
	public static inline var CURRENT_VERSION = 1;

	public static function migrate(raw:Dynamic):ConfigSchema {
		if (raw == null) return defaults();

		var language = Reflect.hasField(raw, "language")
			? Std.string(Reflect.field(raw, "language"))
			: "en";

		var fontScale = 1.0;
		if (Reflect.hasField(raw, "fontScale")) {
			var f = Reflect.field(raw, "fontScale");
			if (Std.isOfType(f, Float) || Std.isOfType(f, Int)) fontScale = f;
			else {
				var parsed = Std.parseFloat(Std.string(f));
				if (!Math.isNaN(parsed)) fontScale = parsed;
			}
		}

		return {
			version:   CURRENT_VERSION,
			language:  language,
			fontScale: fontScale,
		};
	}

	public static inline function defaults():ConfigSchema {
		return { version: CURRENT_VERSION, language: "en", fontScale: 1.0 };
	}
}
