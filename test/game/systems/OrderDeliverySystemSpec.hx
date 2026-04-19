package game.systems;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Dish;
import game.ecs.components.Dish.DishType;
import game.ecs.components.GameStats;
import game.ecs.components.Order;
import game.ecs.components.OrderQueue;
import game.ecs.components.Plate;
import game.ecs.components.ServeWindow;
import game.ecs.components.Surface;
import game.ecs.components.Transform;
import utest.Assert;
import utest.Test;

class OrderDeliverySystemSpec extends Test {
	static function makeServe(w:World, cx:Int, cy:Int, cw:Int, ch:Int):Entity {
		var e = w.create();
		e.add(new Transform(cx * Grid.CELL, cy * Grid.CELL));
		e.add(new Collider(cw * Grid.CELL, ch * Grid.CELL, true));
		e.add(new Surface());
		e.add(new ServeWindow());
		return e;
	}

	static function makePlate(w:World, cx:Int, cy:Int, dish:DishType):Entity {
		var e = w.create();
		var side:Float = 20;
		var px = cx * Grid.CELL + (Grid.CELL - side) * 0.5;
		var py = cy * Grid.CELL + (Grid.CELL - side) * 0.5;
		e.add(new Transform(px, py));
		e.add(new Collider(side, side, false));
		e.add(new Carryable());
		var p = new Plate();
		p.dish = new Dish(dish, []);
		e.add(p);
		return e;
	}

	static function makeQueue(w:World, orders:Array<DishType>):OrderQueue {
		var q = new OrderQueue(8);
		for (d in orders) {
			var oe = w.create();
			oe.add(new Order(d, 30, 10));
			q.orders.push(oe);
		}
		w.create().add(q);
		return q;
	}

	function testMatchingPlateRemovesOrderAndPlate() {
		var w = new World();
		var srv = makeServe(w, 1, 30, 5, 1);
		var q = makeQueue(w, [Sandwich]);
		var plate = makePlate(w, 3, 30, Sandwich);
		srv.get(Surface).place(3, 30, plate);

		new OrderDeliverySystem().update(w, 0);

		Assert.equals(0, q.orders.length);
		Assert.equals(0, w.query(Plate).length);
		Assert.equals(0, w.query(Order).length);
		Assert.isNull(srv.get(Surface).occupantAt(3, 30));
	}

	function testDeliveryIncrementsGameStats() {
		var w = new World();
		var stats = new GameStats();
		w.create().add(stats);
		var srv = makeServe(w, 1, 30, 5, 1);
		makeQueue(w, [Sandwich]);
		var plate = makePlate(w, 3, 30, Sandwich);
		srv.get(Surface).place(3, 30, plate);

		new OrderDeliverySystem().update(w, 0);

		Assert.equals(1,  stats.served);
		Assert.equals(10, stats.money);
		Assert.equals(0,  stats.failed);
	}

	function testMismatchingDishIsNoOp() {
		var w = new World();
		var srv = makeServe(w, 1, 30, 5, 1);
		var q = makeQueue(w, [Sandwich]);
		var plate = makePlate(w, 3, 30, ClassicBurger);
		srv.get(Surface).place(3, 30, plate);

		new OrderDeliverySystem().update(w, 0);

		Assert.equals(1, q.orders.length);
		Assert.equals(1, w.query(Plate).length);
	}

	function testPlateWithoutDishIgnored() {
		var w = new World();
		var srv = makeServe(w, 1, 30, 5, 1);
		var q = makeQueue(w, [Sandwich]);
		var e = w.create();
		e.add(new Transform(3 * Grid.CELL, 30 * Grid.CELL));
		e.add(new Collider(20, 20, false));
		e.add(new Carryable());
		e.add(new Plate()); // dish == null
		srv.get(Surface).place(3, 30, e);

		new OrderDeliverySystem().update(w, 0);

		Assert.equals(1, q.orders.length);
		Assert.equals(1, w.query(Plate).length);
	}

	function testHeldPlateIgnored() {
		var w = new World();
		makeServe(w, 1, 30, 5, 1);
		var q = makeQueue(w, [Sandwich]);
		var plate = makePlate(w, 3, 30, Sandwich);
		plate.get(Carryable).heldBy = w.create();

		new OrderDeliverySystem().update(w, 0);

		Assert.equals(1, q.orders.length);
	}

	function testPlateOffSurfaceIgnored() {
		var w = new World();
		makeServe(w, 1, 30, 5, 1);
		var q = makeQueue(w, [Sandwich]);
		makePlate(w, 20, 30, Sandwich); // outside surface x-range [1..5]

		new OrderDeliverySystem().update(w, 0);

		Assert.equals(1, q.orders.length);
	}

	function testFifoMatchOfDuplicateDish() {
		var w = new World();
		var srv = makeServe(w, 1, 30, 5, 1);
		var q = makeQueue(w, [Sandwich, Sandwich]);
		var firstOrderId = q.orders[0].id;
		var plate = makePlate(w, 3, 30, Sandwich);
		srv.get(Surface).place(3, 30, plate);

		new OrderDeliverySystem().update(w, 0);

		Assert.equals(1, q.orders.length);
		Assert.notEquals(firstOrderId, q.orders[0].id);
	}

	function testEmptyQueueIsNoOp() {
		var w = new World();
		var srv = makeServe(w, 1, 30, 5, 1);
		makeQueue(w, []);
		var plate = makePlate(w, 3, 30, Sandwich);
		srv.get(Surface).place(3, 30, plate);

		new OrderDeliverySystem().update(w, 0);

		Assert.equals(1, w.query(Plate).length);
	}

	function testNoQueueIsNoOp() {
		var w = new World();
		makeServe(w, 1, 30, 5, 1);
		makePlate(w, 3, 30, Sandwich);
		new OrderDeliverySystem().update(w, 0);
		Assert.pass();
	}
}
