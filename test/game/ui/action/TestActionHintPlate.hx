package game.ui.action;

import utest.Assert;
import utest.Test;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Hands;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate;
import game.ecs.components.Surface;
import game.ecs.components.Transform;

class TestActionHintPlate extends Test {
	static inline var CELL = ActionHintFixture.CELL;

	function testHoldingPlateOfferScoop() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);

		var plate = w.create();
		plate.add(new Transform(0, 0));
		plate.add(new Collider(20, 20));
		plate.add(new Carryable());
		plate.add(new Plate());
		p.get(Hands).held = plate;

		var ing = w.create();
		ing.add(new Transform(6 * CELL, 5 * CELL));
		ing.add(new Collider(CELL, CELL));
		ing.add(new Carryable());
		ing.add(new Ingredient(Tomato));

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(1, hints.length);
		Assert.equals("Scoop", hints[0].label);
	}

	function testPlateWithContentsOffersTakeLast() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);

		var plate = w.create();
		plate.add(new Transform(6 * CELL, 5 * CELL));
		plate.add(new Collider(CELL, CELL));
		plate.add(new Carryable());
		var pc = plate.add(new Plate());
		pc.add(Tomato, Raw);

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(2, hints.length);
		Assert.equals("Pickup",    hints[0].label);
		Assert.equals("Take last", hints[1].label);
		Assert.equals("Shift+E",   hints[1].key);
	}

	function testHoldingNonEmptyPlateOfferDropLast() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);

		var plate = w.create();
		plate.add(new Transform(0, 0));
		plate.add(new Collider(20, 20));
		plate.add(new Carryable());
		var pc = plate.add(new Plate());
		pc.add(Tomato, Raw);
		p.get(Hands).held = plate;

		// Empty surface in facing cell.
		var surf = w.create();
		surf.add(new Transform(6 * CELL, 5 * CELL));
		surf.add(new Collider(CELL, CELL));
		surf.add(new Surface());

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(2, hints.length);
		Assert.equals("Place",     hints[0].label);
		Assert.equals("Drop last", hints[1].label);
		Assert.equals("Shift+E",   hints[1].key);
	}

	function testHoldingEmptyPlateNoDropLast() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);

		var plate = w.create();
		plate.add(new Transform(0, 0));
		plate.add(new Collider(20, 20));
		plate.add(new Carryable());
		plate.add(new Plate());
		p.get(Hands).held = plate;

		var surf = w.create();
		surf.add(new Transform(6 * CELL, 5 * CELL));
		surf.add(new Collider(CELL, CELL));
		surf.add(new Surface());

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(1, hints.length);
		Assert.equals("Place", hints[0].label);
	}

	function testEmptyPlateNoTakeLast() {
		var w = new World();
		var p = ActionHintFixture.makePlayer(w);
		var plate = w.create();
		plate.add(new Transform(6 * CELL, 5 * CELL));
		plate.add(new Collider(CELL, CELL));
		plate.add(new Carryable());
		plate.add(new Plate());

		var hints = new ActionHintResolver().resolve(w, p, p.get(Hands));
		Assert.equals(1, hints.length);
		Assert.equals("Pickup", hints[0].label);
	}
}
