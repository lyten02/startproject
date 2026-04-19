package;

import fixtures.GameplayI18nStub;
import utest.Runner;
import utest.ui.Report;

class TestMain {
	public static function main() {
		I18nTestFixture.register(new GameplayI18nStub());
		I18nTestFixture.ensure();
		var r = new Runner();
		TestCollector.addAllCases(r);
		Report.create(r);
		r.run();
	}
}
