package game.core;

import utest.Assert;
import utest.Test;

class TestAABB extends Test {
	function testOverlapsPositive() {
		var a = new AABB(0, 0, 10, 10);
		var b = new AABB(5, 5, 10, 10);
		Assert.isTrue(a.overlaps(b));
	}

	function testOverlapsDisjoint() {
		var a = new AABB(0, 0, 10, 10);
		var b = new AABB(20, 0, 10, 10);
		Assert.isFalse(a.overlaps(b));
	}

	function testTouchingEdgesAreNotOverlapping() {
		// Touching at the right edge should NOT count as overlapping
		// (strict < in AABB prevents corner-sticking in collision response).
		var a = new AABB(0, 0, 10, 10);
		var b = new AABB(10, 0, 10, 10);
		Assert.isFalse(a.overlaps(b));
	}

	function testRightAndBottomAccessors() {
		var a = new AABB(3, 4, 10, 20);
		Assert.equals(13.0, a.right());
		Assert.equals(24.0, a.bottom());
	}

	function testOverlapsRaw() {
		Assert.isTrue(AABB.overlapsRaw(0, 0, 10, 10, 5, 5, 10, 10));
		Assert.isFalse(AABB.overlapsRaw(0, 0, 10, 10, 20, 0, 10, 10));
	}
}
