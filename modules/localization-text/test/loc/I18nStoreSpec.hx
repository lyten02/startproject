package loc;

import loc.base.LocaleId;
import loc.text.I18nStore;
import utest.Assert;
import utest.Test;

class I18nStoreSpec extends Test {
	function testGetMissingReturnsNull() {
		var s = new I18nStore();
		Assert.isNull(s.resolve("missing.key", LocaleId.EN));
		Assert.isFalse(s.has("missing.key", LocaleId.EN));
	}

	function testPutAndGet() {
		var s = new I18nStore();
		s.put(LocaleId.EN, "ui.pause", "PAUSE");
		Assert.equals("PAUSE", s.resolve("ui.pause", LocaleId.EN));
		Assert.isTrue(s.has("ui.pause", LocaleId.EN));
	}

	function testLanguagesAreIsolated() {
		var s = new I18nStore();
		s.put(LocaleId.EN, "ui.pause", "PAUSE");
		Assert.isNull(s.resolve("ui.pause", LocaleId.RU));
	}

	function testPutAllMergesIntoBucket() {
		var s = new I18nStore();
		var entries = new Map<String, String>();
		entries.set("actions.chop", "Chop");
		entries.set("actions.wash", "Wash");
		s.putAll(LocaleId.EN, entries);
		Assert.equals("Chop", s.resolve("actions.chop", LocaleId.EN));
		Assert.equals("Wash", s.resolve("actions.wash", LocaleId.EN));
		Assert.equals(2, s.countOf(LocaleId.EN));
	}

	function testMissingDiffsAgainstBase() {
		var s = new I18nStore();
		s.put(LocaleId.EN, "a", "A");
		s.put(LocaleId.EN, "b", "B");
		s.put(LocaleId.EN, "c", "C");
		s.put(LocaleId.RU, "a", "А");
		var missing = s.missing(LocaleId.RU, LocaleId.EN);
		missing.sort(Reflect.compare);
		Assert.equals(2, missing.length);
		Assert.equals("b", missing[0]);
		Assert.equals("c", missing[1]);
	}

	function testMissingReturnsEmptyWhenComplete() {
		var s = new I18nStore();
		s.put(LocaleId.EN, "a", "A");
		s.put(LocaleId.RU, "a", "А");
		Assert.equals(0, s.missing(LocaleId.RU, LocaleId.EN).length);
	}

	function testClearLang() {
		var s = new I18nStore();
		s.put(LocaleId.EN, "a", "A");
		s.clear(LocaleId.EN);
		Assert.isNull(s.resolve("a", LocaleId.EN));
	}
}
