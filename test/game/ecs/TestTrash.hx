package game.ecs;

import game.ecs.components.Carryable;
import game.ecs.components.Hands;
import game.ecs.components.Trash;
import utest.Assert;
import utest.Test;

/** Trash component + Hands cooldown invariants. */
class TestTrash extends Test {
	function testTrashIsMarker() {
		var e = new Entity(0);
		e.add(new Trash());
		Assert.isTrue(e.has(Trash));
	}

	function testHandsCooldownDefault() {
		var h = new Hands();
		Assert.floatEquals(-1, h.lastTrashStamp);
	}

	function testDisposeClearsHands() {
		// Simulate interact-trash: destroy item, clear held, set stamp.
		var w = new World();
		var item = w.create(); item.add(new Carryable());
		var hands = new Hands();
		hands.held = item;
		// caller logic:
		hands.held = null;
		hands.lastTrashStamp = 1.234;
		w.destroy(item);

		Assert.isNull(hands.held);
		Assert.floatEquals(1.234, hands.lastTrashStamp);
		Assert.equals(0, w.entities.length);
	}

	function testCooldownBlocksWithin300ms() {
		var hands = new Hands();
		hands.lastTrashStamp = 10.0;
		var now = 10.25; // 250 ms after
		Assert.isTrue(now - hands.lastTrashStamp < 0.3);
		now = 10.35;    // 350 ms after
		Assert.isFalse(now - hands.lastTrashStamp < 0.3);
	}
}
