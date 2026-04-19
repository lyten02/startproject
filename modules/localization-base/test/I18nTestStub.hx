package;

import loc.base.LocaleId;

/**
 * A module-scoped bundle of translation stubs for Node.js tests.
 * Register with `I18nTestFixture.register(new XxxI18nStub())` before `ensure()`.
 */
interface I18nTestStub {
	public function locale():LocaleId;
	public function strings():Map<String, String>;
}
