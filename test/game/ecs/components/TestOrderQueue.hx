package game.ecs.components;

import game.ecs.Entity;
import utest.Assert;
import utest.Test;

class TestOrderQueue extends Test {
	function testDefaultsEmpty() {
		var q = new OrderQueue(4);
		Assert.equals(0, q.length());
		Assert.equals(4, q.maxSize);
		Assert.equals(0.0, q.spawnTimerSec);
		Assert.isFalse(q.isFull());
	}

	function testIsFullWhenAtMax() {
		var q = new OrderQueue(2);
		q.orders.push(new Entity(0));
		q.orders.push(new Entity(1));
		Assert.isTrue(q.isFull());
	}

	function testNotFullBelowMax() {
		var q = new OrderQueue(3);
		q.orders.push(new Entity(0));
		Assert.isFalse(q.isFull());
		Assert.equals(1, q.length());
	}
}
