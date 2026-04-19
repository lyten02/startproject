package game.systems;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Hands;
import game.ecs.components.InFlight;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate;
import game.ecs.components.Surface;
import game.ecs.components.Transform;
import game.map.DishFactory;
import game.map.EntityFactory;

/** Stateless plate-container actions: scoop, place onto, take / drop last. */
class PlateActions {
	/** Plate-in-hand + ingredient resting in facing cell → absorb snapshot. */
	public static function tryScoopIntoPlate(world:World, player:Entity, hands:Hands, plate:Plate, cx:Int, cy:Int):Bool {
		var target = InteractQueries.findCarryableAtCell(world, cx, cy);
		if (target == null) return false;
		if (target.has(InFlight)) return false;
		var ing = target.get(Ingredient);
		if (ing == null) return false;
		if (plate.hasStack()) {
			InteractActions.notify(player, "messages.stacked_cant_add", 1.5, 0xFFB347);
			return true;
		}
		if (plate.dish != null) {
			InteractActions.notify(player, "messages.dish_ready_take", 1.5, 0xFFB347);
			return true;
		}
		if (plate.isFull()) {
			InteractActions.notify(player, "messages.plate_full", 1.5, 0xFFB347);
			return true;
		}
		plate.add(ing.type, ing.state, ing.freshness, ing.maxFreshness);
		clearSurfaceOf(world, target);
		EntityDestroyer.destroy(world, target);
		// Held plate just absorbed an ingredient — try to merge.
		if (hands.held != null) PlateMergeSystem.tryMerge(world, hands.held, player);
		return true;
	}

	/** Ingredient-in-hand + resting plate in facing cell → push snapshot. */
	public static function tryPlaceOntoPlate(world:World, player:Entity, hands:Hands, item:Entity, ing:Ingredient, cx:Int, cy:Int):Bool {
		var target = InteractQueries.findCarryableAtCell(world, cx, cy);
		if (target == null) return false;
		var p = target.get(Plate);
		if (p == null) return false;
		if (p.hasStack()) {
			InteractActions.notify(player, "messages.stacked_cant_add", 1.5, 0xFFB347);
			return true;
		}
		if (p.dish != null) {
			InteractActions.notify(player, "messages.dish_ready_take", 1.5, 0xFFB347);
			return true;
		}
		if (p.isFull()) {
			InteractActions.notify(player, "messages.plate_full", 1.5, 0xFFB347);
			return true;
		}
		p.add(ing.type, ing.state, ing.freshness, ing.maxFreshness);
		EntityDestroyer.destroy(world, item);
		hands.held = null;
		PlateMergeSystem.tryMerge(world, target, player);
		return true;
	}

	/** Plate-in-hand + plate resting in facing cell → stack on top. */
	public static function tryStackOntoPlate(world:World, player:Entity, hands:Hands, heldItem:Entity, cx:Int, cy:Int):Bool {
		if (heldItem.get(Plate) == null) return false;
		var target = InteractQueries.findCarryableAtCell(world, cx, cy);
		if (target == null || target == heldItem) return false;
		var base = target.get(Plate);
		if (base == null) return false;
		base.stackedPlates.push(heldItem);
		heldItem.get(Carryable).heldBy = null;
		hands.held = null;
		return true;
	}

	/**
	 * Shift+E with empty hands + facing a plate:
	 *   - If the plate has a stack on top → pop the top stacked plate into hands.
	 *   - Else if the plate has ingredient contents → pop last into hands.
	 */
	public static function takeFromPlate(world:World, player:Entity, hands:Hands):Void {
		if (hands.held != null) return;
		var cell = InteractQueries.facingCell(player);
		var target = InteractQueries.findCarryableAtCell(world, cell.x, cell.y);
		if (target == null) return;
		var plate = target.get(Plate);
		if (plate == null) return;

		if (plate.hasStack()) {
			var top = plate.stackedPlates.pop();
			InteractActions.attachToHands(world, player, hands, top);
			return;
		}
		if (plate.dish != null) {
			var ptr = player.get(Transform);
			var dish = plate.dish;
			plate.dish = null;
			var item = DishFactory.spawnDish(world, ptr.pos.x, ptr.pos.y, dish.type, dish.sourceSlots);
			InteractActions.attachToHands(world, player, hands, item);
			return;
		}
		if (plate.contents.length == 0) return;

		var slot = plate.contents.pop();
		var ptr  = player.get(Transform);
		var item = EntityFactory.spawnIngredient(world, ptr.pos.x, ptr.pos.y, slot.type);
		applySlot(item, slot);
		InteractActions.attachToHands(world, player, hands, item);
	}

	/** Held non-empty plate + empty facing Surface cell → drop last onto cell. */
	public static function dropLastFromHeldPlate(world:World, player:Entity, hands:Hands):Bool {
		if (hands.held == null) return false;
		var plate = hands.held.get(Plate);
		if (plate == null || plate.contents.length == 0) return false;
		var cell = InteractQueries.facingCell(player);
		var surf = InteractQueries.findSurfaceAtCell(world, cell.x, cell.y);
		if (surf == null) return false;
		var sc = surf.get(Surface);
		if (sc.occupantAt(cell.x, cell.y) != null) return false;

		var slot = plate.contents.pop();
		var px = cell.x * Grid.CELL + (Grid.CELL - 20) * 0.5;
		var py = cell.y * Grid.CELL + (Grid.CELL - 20) * 0.5;
		var item = EntityFactory.spawnIngredient(world, px, py, slot.type);
		applySlot(item, slot);
		sc.place(cell.x, cell.y, item);
		return true;
	}

	static inline function applySlot(item:Entity, slot:game.ecs.components.Plate.PlateSlot):Void {
		var ing = item.get(Ingredient);
		ing.state        = slot.state;
		ing.freshness    = slot.freshness;
		ing.maxFreshness = slot.maxFreshness;
	}

	static function clearSurfaceOf(world:World, item:Entity):Void {
		for (s in world.query(Surface)) {
			var sc = s.get(Surface);
			var at = sc.cellOf(item);
			if (at != null) sc.clear(at.cx, at.cy);
		}
	}
}
