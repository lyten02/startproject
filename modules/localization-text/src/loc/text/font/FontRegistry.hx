package loc.text.font;

import h2d.Font;
import loc.base.LocaleId;
import loc.text.I18n;

/**
 * Two-level cache: family → size → h2d.Font.
 * Call `get(size)` to receive the current language's primary font. Callers do
 * not own the Font — it is shared across every ReactiveText / Presenter.
 *
 * Step M (font generation) plugs additional family names into LangFontMap;
 * loadFont resolves them through hxd.Res.loader.load so no callsite changes.
 */
class FontRegistry {
	static var fonts:Map<String, Map<Int, Font>> = new Map();

	public static function get(size:Int):Font {
		return getFor(I18n.current(), size);
	}

	public static function getFor(lang:LocaleId, size:Int):Font {
		var family = LangFontMap.primaryFamily(lang);
		var bucket = fonts.get(family);
		if (bucket == null) {
			bucket = new Map();
			fonts.set(family, bucket);
		}
		var f = bucket.get(size);
		if (f == null) {
			f = loadFont(family, size);
			bucket.set(size, f);
		}
		return f;
	}

	static function loadFont(family:String, size:Int):Font {
		var bm = resolveBitmapFont(family);
		if (bm == null) {
			var fallback = resolveBitmapFont(LangFontMap.fallbackFamily(I18n.current()));
			bm = fallback != null ? fallback : hxd.Res.fonts.Arial_sdf;
		}
		return bm.toSdfFont(size, Alpha);
	}

	static function resolveBitmapFont(family:String):Null<hxd.res.BitmapFont> {
		try {
			return hxd.Res.loader.loadCache("fonts/" + family + ".fnt", hxd.res.BitmapFont);
		} catch (e:Dynamic) {
			return null;
		}
	}
}
