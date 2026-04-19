package game.ecs;

import game.ecs.components.Carryable;
import game.ecs.components.Surface;
import utest.Assert;
import utest.Test;

/** Per-cell placement contract on Surface. Each (cx,cy) is an independent slot. */
class TestSurfaceSlots extends Test {
	function testPlaceAndOccupantAt() {
		var s = new Surface();
		var a = new Entity(1); a.add(new Carryable());
		s.place(3, 7, a);
		Assert.equals(a, s.occupantAt(3, 7));
		Assert.isNull(s.occupantAt(3, 8));
		Assert.isNull(s.occupantAt(0, 0));
	}

	function testMultipleCellsIndependent() {
		var s = new Surface();
		var a = new Entity(1); a.add(new Carryable());
		var b = new Entity(2); b.add(new Carryable());
		s.place(0, 0, a);
		s.place(5, 0, b);
		Assert.equals(a, s.occupantAt(0, 0));
		Assert.equals(b, s.occupantAt(5, 0));
	}

	function testClearLeavesOthersIntact() {
		var s = new Surface();
		var a = new Entity(1); a.add(new Carryable());
		var b = new Entity(2); b.add(new Carryable());
		s.place(1, 1, a);
		s.place(2, 1, b);
		s.clear(1, 1);
		Assert.isNull(s.occupantAt(1, 1));
		Assert.equals(b, s.occupantAt(2, 1));
	}

	function testCellOfReturnsCorrectKey() {
		var s = new Surface();
		var a = new Entity(1); a.add(new Carryable());
		s.place(-4, 9, a);
		var at = s.cellOf(a);
		Assert.notNull(at);
		Assert.equals(-4, at.cx);
		Assert.equals(9, at.cy);
	}

	function testCellOfReturnsNullForMissing() {
		var s = new Surface();
		var a = new Entity(1); a.add(new Carryable());
		Assert.isNull(s.cellOf(a));
	}

	function testPlaceClearRoundTrip() {
		var s = new Surface();
		var a = new Entity(1); a.add(new Carryable());
		s.place(10, 20, a);
		s.clear(10, 20);
		Assert.isNull(s.occupantAt(10, 20));
		Assert.isNull(s.cellOf(a));
	}

	function testPlaceOverwritesSameCell() {
		var s = new Surface();
		var a = new Entity(1); a.add(new Carryable());
		var b = new Entity(2); b.add(new Carryable());
		s.place(4, 4, a);
		s.place(4, 4, b);
		Assert.equals(b, s.occupantAt(4, 4));
		// `a` is no longer tracked by any cell — cellOf should miss.
		Assert.isNull(s.cellOf(a));
	}
}
