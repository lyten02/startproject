package loc.text.font;

import loc.base.LocaleId;

/**
 * Resolves a base font family name for a given language.
 * Latin + Cyrillic + Turkish Extended share NotoSans_sdf (same atlas).
 * CJK uses a dedicated NotoSansSC_sdf atlas — generated once by
 * `python scripts/download_fonts.py`. If the generated .fnt is absent
 * FontRegistry falls back to the bundled Arial_sdf automatically.
 */
class LangFontMap {
	public static function primaryFamily(lang:LocaleId):String {
		return switch ((lang : String)) {
			case "zh": "NotoSansSC_sdf";
			default:   "NotoSans_sdf";
		}
	}

	public static function fallbackFamily(lang:LocaleId):String {
		return "Arial_sdf";
	}
}
