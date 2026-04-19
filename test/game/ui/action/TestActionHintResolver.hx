package game.ui.action;

import utest.Assert;
import utest.Test;
import game.core.ThrowPhysics;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Dispenser;
import game.ecs.components.Hands;
import game.ecs.components.InFlight;
import game.ecs.components.Surface;
import game.ecs.components.Transform;
import game.ecs.components.Trash;

class TestActionHintResolver extends Test {
	static inline var CELL = ActionHintFixture.CELL;

	function testEmptyHandsPickup() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);
		ActionHintFixture.makeItem(w, 6, 5);

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(1, hints.length);
		Assert.equals("E", hints[0].key);
		Assert.equals("Pickup", hints[0].label);
		Assert.isTrue(hints[0].enabled);
	}

	function testEmptyHandsEmptyCellHidesHud() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(0, hints.length);
	}

	function testEmptyHandsEmptyDispenserHides() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);

		var d = w.create();
		d.add(new Transform(6 * CELL, 5 * CELL));
		d.add(new Collider(CELL, CELL));
		d.add(new Dispenser(0));

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(0, hints.length);
	}

	function testFullHandsTrash() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);
		var item = ActionHintFixture.makeItem(w, 0, 0);
		p.get(Hands).held = item;

		var t = w.create();
		t.add(new Transform(6 * CELL, 5 * CELL));
		t.add(new Collider(CELL, CELL));
		t.add(new Trash());

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals("Trash", hints[0].label);
		Assert.isTrue(hints[0].enabled);
	}

	function testFullHandsBusySurfaceHides() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);
		var item = ActionHintFixture.makeItem(w, 0, 0);
		p.get(Hands).held = item;

		var s = w.create();
		s.add(new Transform(6 * CELL, 5 * CELL));
		s.add(new Collider(CELL, CELL));
		var sc = s.add(new Surface());

		var occupant = w.create();
		sc.place(6, 5, occupant);

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(0, hints.length);
	}

	function testFullHandsEmptyCellPromptsThrow() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);
		var item = ActionHintFixture.makeItem(w, 0, 0);
		p.get(Hands).held = item;

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(1, hints.length);
		Assert.equals("Hold E", hints[0].key);
		Assert.equals("Throw", hints[0].label);
	}

	function testFlyingItemOffersCatch() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);
		var plate = ActionHintFixture.makeItem(w, 6, 5);
		plate.add(new InFlight(0, 0, 0));

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(1, hints.length);
		Assert.equals("Catch", hints[0].label);
	}

	function testFlyingItemOutOfRange() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);
		var plate = ActionHintFixture.makeItem(w, 8, 5);
		plate.add(new InFlight(0, 0, 0));

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(0, hints.length);
	}

	function testChargingHidesContextHud() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);
		var item = ActionHintFixture.makeItem(w, 0, 0);
		var h = p.get(Hands);
		h.held = item;
		h.charging = true;
		h.chargeSec = ThrowPhysics.MIN_CHARGE + (ThrowPhysics.MAX_CHARGE - ThrowPhysics.MIN_CHARGE) * 0.5;

		var hints = new ActionHintResolver().resolve(w, p, h);
		Assert.equals(0, hints.length);
	}
}
