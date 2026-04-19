package;

import loc.text.I18n;

/**
 * Thin registry of per-module I18nTestStub's. Modules (or the project) call
 * `register(...)` from their test bootstrap, then TestMain calls `ensure()`
 * which flushes all stubs into I18n. The nodejs test target cannot read from
 * hxd.Res, so every UI string touched by a test must have a stub entry.
 */
class I18nTestFixture {
	static var stubs:Array<I18nTestStub> = [];
	static var applied:Bool = false;

	public static function register(stub:I18nTestStub):Void {
		stubs.push(stub);
	}

	public static function ensure():Void {
		if (applied) return;
		applied = true;
		for (s in stubs) I18n.feedFlat(s.locale(), s.strings());
	}
}
