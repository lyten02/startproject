package game.systems;

import utest.Assert;
import utest.Test;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;

class TestCollisionSystem extends Test {
	function testClampsToBoundsLeft() {
		var w   = new World();
		var sys = new CollisionSystem();
		sys.boundsW = 500; sys.boundsH = 500;

		var e = w.create();
		var tr = e.add(new Transform(-100, 50));
		e.add(new Collider(32, 32));
		e.add(new Velocity());

		sys.update(w, 1 / 60);
		Assert.equals(0.0, tr.pos.x);
	}

	function testClampsToBoundsRight() {
		var w   = new World();
		var sys = new CollisionSystem();
		sys.boundsW = 500; sys.boundsH = 500;

		var e = w.create();
		var tr = e.add(new Transform(600, 50));
		e.add(new Collider(32, 32));
		e.add(new Velocity());

		sys.update(w, 1 / 60);
		Assert.equals(500.0 - 32, tr.pos.x);
	}

	function testBlocksMovementIntoSolid() {
		var w   = new World();
		var sys = new CollisionSystem();

		// Static solid at (100, 0) size 32×32.
		var wall = w.create();
		wall.add(new Transform(100, 0));
		wall.add(new Collider(32, 32, true));

		// Mover next to it, velocity pushing right, will penetrate in one frame.
		var mover = w.create();
		var mt = mover.add(new Transform(90, 0));
		mover.add(new Collider(32, 32));
		var vel = mover.add(new Velocity());
		vel.v.set(1000, 0);  // big push

		sys.update(w, 1 / 60);
		// Expected: pushed back to touch wall left edge (100 - 32 = 68).
		Assert.equals(68.0, mt.pos.x);
	}

	function testSolidDoesNotMove() {
		var w   = new World();
		var sys = new CollisionSystem();

		var wall = w.create();
		var wt = wall.add(new Transform(100, 100));
		wall.add(new Collider(32, 32, true));
		// No Velocity → not processed.

		sys.update(w, 1 / 60);
		Assert.equals(100.0, wt.pos.x);
		Assert.equals(100.0, wt.pos.y);
	}
}
