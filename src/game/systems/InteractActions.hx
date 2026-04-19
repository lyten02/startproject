package game.systems;

import game.core.Grid;
import game.core.ThrowPhysics;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.ActionFeedback;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Dispenser;
import game.ecs.components.Facing;
import game.ecs.components.Hands;
import game.ecs.components.InFlight;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate;
import game.ecs.components.SinkQueue;
import game.ecs.components.Station;
import game.ecs.components.Station.StationKind;
import game.ecs.components.Surface;
import game.ecs.components.Transform;
import game.map.EntityFactory;

/** Stateless action resolvers invoked by InteractSystem on tap/release. */
class InteractActions {
	public static function tryPickup(world:World, player:Entity, hands:Hands):Void {
		var pc = InteractQueries.playerCentre(player);
		var flying = InteractQueries.findCatchableNear(world, pc.x, pc.y);
		if (flying != null) {
			flying.remove(InFlight);
			attachToHands(world, player, hands, flying);
			notify(player, "messages.caught", 0.6, 0x7CFC8A);
			return;
		}

		var cell = InteractQueries.facingCell(player);
		var item = InteractQueries.findCarryableAtCell(world, cell.x, cell.y);
		if (item != null && !item.has(InFlight)) {
			attachToHands(world, player, hands, item);
			return;
		}

		var dispenser = InteractQueries.findDispenserAtCell(world, cell.x, cell.y);
		if (dispenser == null) return;
		var d = dispenser.get(Dispenser);
		if (d.stock <= 0) return;
		var px = cell.x * Grid.CELL + (Grid.CELL - 20) * 0.5;
		var py = cell.y * Grid.CELL + (Grid.CELL - 20) * 0.5;
		var spawned = d.ingredient != null && d.ingredient != ""
			? EntityFactory.spawnIngredient(world, px, py, EntityFactory.ingredientFromId(d.ingredient))
			: EntityFactory.spawnPlate(world, px, py);
		d.stock--;
		attachToHands(world, player, hands, spawned);
	}

	public static function tryPlace(world:World, player:Entity, hands:Hands):Void {
		var cell = InteractQueries.facingCell(player);
		var item = hands.held;
		var ic   = item.get(Collider);

		var heldPlate = item.get(Plate);
		if (heldPlate != null && PlateActions.tryScoopIntoPlate(world, player, hands, heldPlate, cell.x, cell.y)) return;
		if (heldPlate != null && PlateActions.tryStackOntoPlate(world, player, hands, item, cell.x, cell.y)) return;

		var ing = item.get(Ingredient);
		if (ing != null && PlateActions.tryPlaceOntoPlate(world, player, hands, item, ing, cell.x, cell.y)) return;

		var trash = InteractQueries.findTrashAtCell(world, cell.x, cell.y);
		if (trash != null) {
			var now = haxe.Timer.stamp();
			if (now - hands.lastTrashStamp < 0.3) return;
			EntityDestroyer.destroy(world, item);
			hands.held = null;
			hands.lastTrashStamp = now;
			return;
		}

		var surf = InteractQueries.findSurfaceAtCell(world, cell.x, cell.y);
		if (surf != null) {
			var station = surf.get(Station);
			// Sink + plate → push into queue (stackable), skip occupancy rules.
			if (station != null && station.kind == Sink && item.get(Plate) != null) {
				var q = surf.get(SinkQueue);
				if (q != null) {
					if (q.isFull()) { notify(player, "messages.sink_full", 1.5, 0xFFB347); return; }
					q.push(item);
					item.get(Carryable).heldBy = null;
					hands.held = null;
					return;
				}
			}
			var sc = surf.get(Surface);
			if (sc.occupantAt(cell.x, cell.y) != null) {
				notify(player, "messages.cell_busy", 1.5, 0xFFB347);
				return;
			}
			if (ing != null && station != null) {
				if (ing.state == Burnt || ing.state == Spoiled) {
					notify(player, "messages.cant_process", 1.8, 0xFF6060);
					return;
				}
			}
			placeAtCell(item, ic, cell.x, cell.y);
			sc.place(cell.x, cell.y, item);
		} else {
			placeAtCell(item, ic, cell.x, cell.y);
		}

		item.get(Carryable).heldBy = null;
		hands.held = null;
	}

	public static function doThrow(world:World, player:Entity, hands:Hands):Void {
		var fc = player.get(Facing);
		if (fc == null) return;
		notify(player, "messages.returning", 0.8, 0x7CFC8A);
		var item = hands.held;
		var ptr = player.get(Transform);
		var pc  = player.get(Collider);
		var ic  = item.get(Collider);
		var pcx = Math.floor((ptr.pos.x + pc.w * 0.5) / Grid.CELL);
		var pcy = Math.floor((ptr.pos.y + pc.h * 0.5) / Grid.CELL);
		placeAtCell(item, ic, pcx, pcy);

		var speed = ThrowPhysics.chargeToSpeed(hands.chargeSec);
		item.add(new InFlight(fc.dx * speed, fc.dy * speed, ThrowPhysics.LAUNCH_VZ, 1));
		item.get(Carryable).heldBy = null;
		hands.held = null;
	}

	public static function notify(player:Entity, msgKey:String, ttl:Float, color:Int, ?args:loc.base.I18nContract.PlaceholderArgs):Void {
		var fb = player.get(ActionFeedback);
		if (fb != null) fb.set(msgKey, ttl, color, args);
	}

	public static function attachToHands(world:World, player:Entity, hands:Hands, item:Entity):Void {
		item.get(Carryable).heldBy = player;
		hands.held = item;
		// Picking up an ingredient cancels any in-progress cooking on the station.
		var ing = item.get(Ingredient);
		if (ing != null) ing.processedTime = 0;
		for (s in world.query(Surface)) {
			var sc = s.get(Surface);
			var at = sc.cellOf(item);
			if (at != null) sc.clear(at.cx, at.cy);
		}
	}

	static function placeAtCell(item:Entity, ic:Collider, cx:Int, cy:Int):Void {
		var itr = item.get(Transform);
		itr.pos.x = cx * Grid.CELL + (Grid.CELL - ic.w) * 0.5;
		itr.pos.y = cy * Grid.CELL + (Grid.CELL - ic.h) * 0.5;
	}
}
