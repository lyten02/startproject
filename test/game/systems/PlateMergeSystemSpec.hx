package game.systems;

import utest.Assert;
import utest.Test;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Dish.DishType;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate;

class PlateMergeSystemSpec extends Test {
	static function plate(world:World):Entity {
		var e = world.create();
		e.add(new Plate());
		return e;
	}

	function testMatchClearsContentsAndSetsDish() {
		var w = new World();
		var e = plate(w);
		var p = e.get(Plate);
		p.add(Bread, Raw);
		p.add(Cheese, Raw);

		var merged = PlateMergeSystem.tryMerge(w, e, null);
		Assert.isTrue(merged);
		Assert.equals(0, p.contents.length);
		Assert.notNull(p.dish);
		Assert.equals(Sandwich, p.dish.type);
		Assert.equals(2, p.dish.sourceSlots.length);
	}

	function testNoMatchLeavesContentsIntact() {
		var w = new World();
		var e = plate(w);
		var p = e.get(Plate);
		p.add(Bread, Raw);
		p.add(Onion, Raw);

		var merged = PlateMergeSystem.tryMerge(w, e, null);
		Assert.isFalse(merged);
		Assert.equals(2, p.contents.length);
		Assert.isNull(p.dish);
	}

	function testAlreadyMergedIsIdempotent() {
		var w = new World();
		var e = plate(w);
		var p = e.get(Plate);
		p.add(Bread, Raw);
		p.add(Cheese, Raw);
		PlateMergeSystem.tryMerge(w, e, null);

		var mergedAgain = PlateMergeSystem.tryMerge(w, e, null);
		Assert.isFalse(mergedAgain);
		Assert.notNull(p.dish);
	}

	function testStackedPlateDoesNotMerge() {
		var w = new World();
		var base = plate(w);
		var top  = plate(w);
		var bp = base.get(Plate);
		bp.add(Bread, Raw);
		bp.add(Cheese, Raw);
		bp.stackedPlates.push(top);

		var merged = PlateMergeSystem.tryMerge(w, base, null);
		Assert.isFalse(merged);
		Assert.isNull(bp.dish);
	}

	function testEmptyPlateDoesNotMerge() {
		var w = new World();
		var e = plate(w);
		Assert.isFalse(PlateMergeSystem.tryMerge(w, e, null));
	}
}
