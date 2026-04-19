package game.core;

import utest.Assert;
import utest.Test;

class TestTimeScale extends Test {
	function testDefaultsTo1x() {
		var t = new TimeScale();
		Assert.floatEquals(1.0, t.value());
	}

	function testUpSteps() {
		var t = new TimeScale();
		Assert.isTrue(t.up());
		Assert.floatEquals(1.5, t.value());
		t.up(); t.up(); t.up(); t.up();
		Assert.isTrue(t.isMax());
		Assert.floatEquals(10.0, t.value());
	}

	function testDownSteps() {
		var t = new TimeScale();
		Assert.isTrue(t.down());
		Assert.floatEquals(0.75, t.value());
		t.down(); t.down(); t.down();
		Assert.isTrue(t.isMin());
		Assert.floatEquals(0.25, t.value());
	}

	function testLabelFor() {
		Assert.equals("1.0x",  TimeScale.labelFor(1.0));
		Assert.equals("0.25x", TimeScale.labelFor(0.25));
		Assert.equals("10.0x", TimeScale.labelFor(10.0));
	}

	function testClampsAtEdges() {
		var t = new TimeScale();
		while (t.up()) {}
		Assert.isFalse(t.up());
		Assert.floatEquals(10.0, t.value());
		while (t.down()) {}
		Assert.isFalse(t.down());
		Assert.floatEquals(0.25, t.value());
	}
}
