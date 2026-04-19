package game.systems;

import game.ecs.World;
import game.ecs.components.Dish.DishType;
import game.ecs.components.Order;
import game.ecs.components.OrderQueue;
import game.orders.OrderConfig;
import utest.Assert;
import utest.Test;

class OrderSpawnSystemSpec extends Test {
	static function configWith(interval:Float, maxSize:Int):OrderConfig {
		return {
			baseSpawnIntervalSec: interval,
			maxQueueSize:         maxSize,
			dishes: [
				{ dishType: Sandwich,      patienceSec: 30, reward: 10 },
				{ dishType: ClassicBurger, patienceSec: 60, reward: 20 },
			],
		};
	}

	static function setupWorld(maxSize:Int):World {
		var w = new World();
		w.create().add(new OrderQueue(maxSize));
		return w;
	}

	static function queueOf(w:World):OrderQueue {
		return w.query(OrderQueue)[0].get(OrderQueue);
	}

	function testSpawnsOneOrderAfterInterval() {
		var w = setupWorld(4);
		var sys = new OrderSpawnSystem(configWith(20, 4), () -> 0.0);
		sys.update(w, 19.9);
		Assert.equals(0, queueOf(w).length());
		sys.update(w, 0.2);
		Assert.equals(1, queueOf(w).length());
		var o = queueOf(w).orders[0].get(Order);
		Assert.equals(Sandwich, o.dishType);
		Assert.equals(30.0, o.patienceSec);
	}

	function testStopsSpawningAtMaxQueueSize() {
		var w = setupWorld(2);
		var sys = new OrderSpawnSystem(configWith(5, 2), () -> 0.0);
		sys.update(w, 5);
		sys.update(w, 5);
		sys.update(w, 5);
		Assert.equals(2, queueOf(w).length());
	}

	function testResumesAfterSlotFreed() {
		var w = setupWorld(1);
		var sys = new OrderSpawnSystem(configWith(5, 1), () -> 0.0);
		sys.update(w, 5);
		Assert.equals(1, queueOf(w).length());
		sys.update(w, 20);
		Assert.equals(1, queueOf(w).length());
		queueOf(w).orders = [];
		sys.update(w, 5);
		Assert.equals(1, queueOf(w).length());
	}

	function testZeroDtDoesNotAdvanceTimer() {
		var w = setupWorld(4);
		var sys = new OrderSpawnSystem(configWith(5, 4), () -> 0.0);
		for (_ in 0...10) sys.update(w, 0);
		Assert.equals(0, queueOf(w).length());
		Assert.equals(0.0, queueOf(w).spawnTimerSec);
	}

	function testScaledDtSpeedsUpSpawn() {
		var w = setupWorld(4);
		var sys = new OrderSpawnSystem(configWith(20, 4), () -> 0.0);
		sys.update(w, 40);
		Assert.equals(2, queueOf(w).length());
	}

	function testRngSelectsFromPool() {
		var w = setupWorld(4);
		var sys = new OrderSpawnSystem(configWith(1, 4), () -> 0.99);
		sys.update(w, 1);
		var o = queueOf(w).orders[0].get(Order);
		Assert.equals(ClassicBurger, o.dishType);
	}

	function testFullQueueResetsSpawnTimer() {
		var w = setupWorld(1);
		var sys = new OrderSpawnSystem(configWith(5, 1), () -> 0.0);
		sys.update(w, 5);
		sys.update(w, 3);
		Assert.equals(0.0, queueOf(w).spawnTimerSec);
	}

	function testNoQueueNoSpawn() {
		var w = new World();
		var sys = new OrderSpawnSystem(configWith(1, 4), () -> 0.0);
		sys.update(w, 10);
		Assert.equals(0, w.query(Order).length);
	}
}
