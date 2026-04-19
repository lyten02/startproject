package loc;

import loc.text.config.ConfigMigrator;
import utest.Assert;
import utest.Test;

class ConfigMigratorSpec extends Test {
	function testNullReturnsDefaults() {
		var cfg = ConfigMigrator.migrate(null);
		Assert.equals(ConfigMigrator.CURRENT_VERSION, cfg.version);
		Assert.equals("en", cfg.language);
		Assert.equals(1.0, cfg.fontScale);
	}

	function testEmptyObjectFallsBackToDefaults() {
		var cfg = ConfigMigrator.migrate({});
		Assert.equals("en", cfg.language);
		Assert.equals(1.0, cfg.fontScale);
	}

	function testExplicitLanguage() {
		var cfg = ConfigMigrator.migrate({ version: 1, language: "ru", fontScale: 1.25 });
		Assert.equals("ru", cfg.language);
		Assert.equals(1.25, cfg.fontScale);
	}

	function testUnknownVersionIsBumped() {
		var cfg = ConfigMigrator.migrate({ version: 0, language: "tr" });
		Assert.equals(ConfigMigrator.CURRENT_VERSION, cfg.version);
		Assert.equals("tr", cfg.language);
		Assert.equals(1.0, cfg.fontScale);
	}

	function testStringFontScaleParsed() {
		var cfg = ConfigMigrator.migrate({ language: "de", fontScale: "0.85" });
		Assert.equals("de", cfg.language);
		Assert.equals(0.85, cfg.fontScale);
	}

	function testInvalidFontScaleFallsBack() {
		var cfg = ConfigMigrator.migrate({ fontScale: "NaN-junk" });
		Assert.equals(1.0, cfg.fontScale);
	}

	function testUnknownFieldsDropped() {
		var cfg = ConfigMigrator.migrate({ language: "zh", deprecatedFlag: true, extra: 42 });
		Assert.equals("zh", cfg.language);
	}
}
