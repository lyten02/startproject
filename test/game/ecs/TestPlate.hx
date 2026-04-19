package game.ecs;

import utest.Assert;
import utest.Test;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate;

class TestPlate extends Test {
	function testEmptyDefaults() {
		var p = new Plate();
		Assert.equals(0, p.contents.length);
		Assert.isFalse(p.isFull());
	}

	function testAddAppendsSnapshot() {
		var p = new Plate();
		p.add(Tomato, Raw);
		p.add(Meat, Cooked);
		Assert.equals(2, p.contents.length);
		Assert.equals(Tomato, p.contents[0].type);
		Assert.equals(Cooked, p.contents[1].state);
	}

	function testStackedPlatesDefault() {
		var p = new Plate();
		Assert.equals(0, p.stackedPlates.length);
		Assert.isFalse(p.hasStack());
	}

	function testDirtyDefault() {
		var p = new Plate();
		Assert.isFalse(p.dirty);
		p.dirty = true;
		Assert.isTrue(p.dirty);
	}

	function testFullAtMax() {
		var p = new Plate();
		for (i in 0...Plate.MAX) p.add(Bread, Raw);
		Assert.isTrue(p.isFull());
		Assert.equals(Plate.MAX, p.contents.length);
	}
}
