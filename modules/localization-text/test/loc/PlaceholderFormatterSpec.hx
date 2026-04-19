package loc;

import loc.text.PlaceholderFormatter;
import utest.Assert;
import utest.Test;

class PlaceholderFormatterSpec extends Test {
	function testNullTemplateReturnsEmpty() {
		Assert.equals("", PlaceholderFormatter.format(null, null));
	}

	function testNoPlaceholdersNoArgs() {
		Assert.equals("PAUSE", PlaceholderFormatter.format("PAUSE"));
	}

	function testSinglePlaceholderReplaced() {
		var args:haxe.DynamicAccess<String> = new haxe.DynamicAccess();
		args.set("name", "Burger");
		Assert.equals("Burger ready!", PlaceholderFormatter.format("{name} ready!", args));
	}

	function testMultiplePlaceholdersReplaced() {
		var args:haxe.DynamicAccess<String> = new haxe.DynamicAccess();
		args.set("count", "3");
		args.set("max", "5");
		Assert.equals("3 of 5 left", PlaceholderFormatter.format("{count} of {max} left", args));
	}

	function testUnknownPlaceholderKeptLiteral() {
		var args:haxe.DynamicAccess<String> = new haxe.DynamicAccess();
		args.set("known", "A");
		Assert.equals("A and {unknown}", PlaceholderFormatter.format("{known} and {unknown}", args));
	}

	function testExtraArgIgnored() {
		var args:haxe.DynamicAccess<String> = new haxe.DynamicAccess();
		args.set("name", "X");
		args.set("unused", "Y");
		Assert.equals("X ready", PlaceholderFormatter.format("{name} ready", args));
	}

	function testUnresolvedPlaceholders() {
		var args:haxe.DynamicAccess<String> = new haxe.DynamicAccess();
		args.set("a", "A");
		var unresolved = PlaceholderFormatter.unresolvedPlaceholders("{a} + {b} + {c}", args);
		unresolved.sort(Reflect.compare);
		Assert.equals(2, unresolved.length);
		Assert.equals("b", unresolved[0]);
		Assert.equals("c", unresolved[1]);
	}
}
