package game.ecs;

import utest.Assert;
import utest.Test;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;

class TestEntity extends Test {
	function testAddGetHas() {
		var e = new Entity(1);
		var t = new Transform(5, 10);
		e.add(t);
		Assert.isTrue(e.has(Transform));
		Assert.equals(t, e.get(Transform));
	}

	function testMissingComponentIsNull() {
		var e = new Entity(1);
		Assert.isNull(e.get(Velocity));
		Assert.isFalse(e.has(Velocity));
	}

	function testRemove() {
		var e = new Entity(1);
		e.add(new Transform(0, 0));
		e.remove(Transform);
		Assert.isFalse(e.has(Transform));
	}
}
