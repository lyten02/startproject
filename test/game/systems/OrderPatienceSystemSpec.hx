package game.systems;

import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Dish.DishType;
import game.ecs.components.GameStats;
import game.ecs.components.Order;
import game.ecs.components.OrderQueue;
import utest.Assert;
import utest.Test;

class OrderPatienceSystemSpec extends Test {
	static function worldWithOrder(patience:Float):{w:World, oEnt:Entity, q:OrderQueue} {
		var w = new World();
		var q = new OrderQueue(4);
		w.create().add(q);
		var e = w.create();
		e.add(new Order(Sandwich, patience, 0));
		q.orders.push(e);
		return { w: w, oEnt: e, q: q };
	}

	function testDecrementsByDt() {
		var ctx = worldWithOrder(30);
		var sys = new OrderPatienceSystem();
		sys.update(ctx.w, 5);
		var o = ctx.oEnt.get(Order);
		Assert.equals(25.0, o.patienceSec);
		Assert.equals(5.0, o.ageSec);
	}

	function testZeroDtPause() {
		var ctx = worldWithOrder(30);
		var sys = new OrderPatienceSystem();
		sys.update(ctx.w, 0);
		var o = ctx.oEnt.get(Order);
		Assert.equals(30.0, o.patienceSec);
		Assert.equals(0.0, o.ageSec);
		Assert.equals(1, ctx.q.orders.length);
	}

	function testRemovesExpiredOrder() {
		var ctx = worldWithOrder(3);
		var sys = new OrderPatienceSystem();
		sys.update(ctx.w, 10);
		Assert.equals(0, ctx.q.orders.length);
		Assert.equals(0, ctx.w.query(Order).length);
	}

	function testLivesUntilExactlyZero() {
		var ctx = worldWithOrder(5);
		var sys = new OrderPatienceSystem();
		sys.update(ctx.w, 4);
		Assert.equals(1, ctx.q.orders.length);
		sys.update(ctx.w, 1);
		Assert.equals(0, ctx.q.orders.length);
	}

	function testEmptyWorldIsNoOp() {
		var sys = new OrderPatienceSystem();
		sys.update(new World(), 1);
		Assert.pass();
	}

	function testNoQueueIsNoOp() {
		var w = new World();
		var e = w.create();
		e.add(new Order(Sandwich, 10, 0));
		var sys = new OrderPatienceSystem();
		sys.update(w, 1);
		Assert.notNull(e.get(Order));
	}

	function testExpiryIncrementsFailedStat() {
		var w = new World();
		var q = new OrderQueue(4);
		w.create().add(q);
		var stats = new GameStats();
		w.create().add(stats);
		var e = w.create();
		e.add(new Order(Sandwich, 1, 0));
		q.orders.push(e);

		new OrderPatienceSystem().update(w, 5);

		Assert.equals(1, stats.failed);
		Assert.equals(0, stats.served);
	}

	function testRemovesMultipleExpiredInSameTick() {
		var w = new World();
		var q = new OrderQueue(4);
		w.create().add(q);
		for (_ in 0...3) {
			var e = w.create();
			e.add(new Order(Sandwich, 2, 0));
			q.orders.push(e);
		}
		new OrderPatienceSystem().update(w, 5);
		Assert.equals(0, q.orders.length);
		Assert.equals(0, w.query(Order).length);
	}
}
