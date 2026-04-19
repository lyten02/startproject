package game.ecs;

import game.ecs.components.Carryable;
import game.ecs.components.Dispenser;
import game.ecs.components.Hands;
import game.ecs.components.InFlight;
import game.ecs.components.Surface;
import utest.Assert;
import utest.Test;

/** Contract tests for hands/items ECS: defaults + state transitions. */
class TestInteractComponents extends Test {
	function testHandsDefaultEmpty() {
		var h = new Hands();
		Assert.isNull(h.held);
		Assert.isFalse(h.charging);
		Assert.floatEquals(0, h.chargeSec);
	}

	function testSurfaceDefaultUnoccupied() {
		var s = new Surface();
		Assert.isNull(s.occupantAt(0, 0));
		Assert.isNull(s.occupantAt(42, -7));
	}

	function testDispenserDefaults() {
		Assert.equals(0, new Dispenser().stock);
		Assert.equals(3, new Dispenser(3).stock);
	}

	function testPickupTransition() {
		var w = new World();
		var player = w.create(); player.add(new Hands());
		var plate  = w.create(); plate.add(new Carryable());
		var table  = w.create(); table.add(new Surface());

		table.get(Surface).place(5, 2, plate);
		// Pickup.
		var hands = player.get(Hands);
		hands.held = plate;
		plate.get(Carryable).heldBy = player;
		var at = table.get(Surface).cellOf(plate);
		Assert.notNull(at);
		table.get(Surface).clear(at.cx, at.cy);

		Assert.equals(plate, hands.held);
		Assert.equals(player, plate.get(Carryable).heldBy);
		Assert.isNull(table.get(Surface).occupantAt(5, 2));
	}

	function testInFlightAttachDetach() {
		var plate = new Entity(0);
		plate.add(new Carryable());
		Assert.isFalse(plate.has(InFlight));
		plate.add(new InFlight(100, 0, 200));
		Assert.isTrue(plate.has(InFlight));
		plate.remove(InFlight);
		Assert.isFalse(plate.has(InFlight));
	}

	function testDispenserStockDecrement() {
		var d = new Dispenser(3);
		d.stock--;
		Assert.equals(2, d.stock);
		d.stock--;
		d.stock--;
		Assert.equals(0, d.stock);
	}
}
