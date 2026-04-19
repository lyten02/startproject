package game.core;

import utest.Assert;
import utest.Test;

class TestVec2 extends Test {
	function testNewDefaultsToZero() {
		var v = new Vec2();
		Assert.equals(0.0, v.x);
		Assert.equals(0.0, v.y);
	}

	function testSet() {
		var v = new Vec2();
		v.set(3, 4);
		Assert.equals(3.0, v.x);
		Assert.equals(4.0, v.y);
	}

	function testAdd() {
		var v = new Vec2(1, 2);
		v.add(10, 20);
		Assert.equals(11.0, v.x);
		Assert.equals(22.0, v.y);
	}

	function testEqualsAndClone() {
		var a = new Vec2(5, 6);
		var b = a.clone();
		Assert.isTrue(a.equals(b));
		b.x = 0;
		Assert.isFalse(a.equals(b));
	}
}
