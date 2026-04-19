package game.ecs;

import utest.Assert;
import utest.Test;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;

class TestWorld extends Test {
	function testCreateIncrementsCount() {
		var w = new World();
		Assert.equals(0, w.count());
		w.create();
		w.create();
		Assert.equals(2, w.count());
	}

	function testUniqueIds() {
		var w = new World();
		var a = w.create();
		var b = w.create();
		Assert.notEquals(a.id, b.id);
	}

	function testDestroy() {
		var w = new World();
		var e = w.create();
		w.destroy(e);
		Assert.equals(0, w.count());
	}

	function testQueryFiltersByComponent() {
		var w = new World();
		var a = w.create(); a.add(new Transform(0, 0));
		var b = w.create(); b.add(new Transform(0, 0)); b.add(new Velocity());
		var c = w.create();

		Assert.equals(2, w.query(Transform).length);
		Assert.equals(1, w.query(Velocity).length);
	}
}
