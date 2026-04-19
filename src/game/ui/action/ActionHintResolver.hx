package game.ui.action;

import game.core.ThrowPhysics;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Dispenser;
import game.ecs.components.Hands;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate;
import game.ecs.components.Station;
import game.ecs.components.Station.StationKind;
import game.ecs.components.Surface;
import game.i18n.GameI18n;
import game.systems.InteractQueries;
import loc.base.I18nContract.PlaceholderArgs;
import loc.text.I18n;

/**
 * Pure contextual hint resolver. No Heaps/UI.
 * Reads world + hands + facing-cell and returns hints for ActionHudView.
 * Labels are resolved via I18n.t against the `actions.*` namespace — calling
 * resolve() each frame keeps labels current when the language changes.
 */
class ActionHintResolver {
	public function new() {}

	public function resolve(world:World, player:Entity, hands:Hands):Array<ActionHint> {
		if (hands.charging && hands.chargeSec >= ThrowPhysics.MIN_CHARGE && hands.held != null) {
			return [];
		}
		var cell = InteractQueries.facingCell(player);
		if (hands.held == null) {
			var pc = InteractQueries.playerCentre(player);
			if (InteractQueries.findCatchableNear(world, pc.x, pc.y) != null) {
				return [hintKey("E", "actions.catch")];
			}
			return emptyHandsHints(world, cell.x, cell.y);
		}
		return fullHandsHints(world, cell.x, cell.y, hands);
	}

	function emptyHandsHints(world:World, cx:Int, cy:Int):Array<ActionHint> {
		var item = InteractQueries.findCarryableAtCell(world, cx, cy);
		if (item != null) {
			var plate = item.get(Plate);
			if (plate != null && plate.hasStack()) {
				return [hintKey("E", "actions.pickup"), hintKey("Shift+E", "actions.take_top")];
			}
			if (plate != null && plate.contents.length > 0) {
				return [hintKey("E", "actions.pickup"), hintKey("Shift+E", "actions.take_last")];
			}
			var holdHint = interactiveStationHint(world, cx, cy, item, plate);
			if (holdHint != null) return [hintKey("E", "actions.pickup"), holdHint];
			return [hintKey("E", "actions.pickup")];
		}

		var disp = InteractQueries.findDispenserAtCell(world, cx, cy);
		if (disp != null) {
			var d = disp.get(Dispenser);
			if (d.stock > 0) {
				if (d.ingredient != null && d.ingredient != "") {
					var args:PlaceholderArgs = new haxe.DynamicAccess<String>();
					args.set("item", GameI18n.ingredientNameById(d.ingredient));
					return [hintKey("E", "actions.take", args)];
				}
				return [hintKey("E", "actions.take_plate")];
			}
		}
		return [];
	}

	function interactiveStationHint(world:World, cx:Int, cy:Int, target:Entity, plate:Plate):ActionHint {
		var surf = InteractQueries.findSurfaceAtCell(world, cx, cy);
		if (surf == null) return null;
		var st = surf.get(Station);
		if (st == null || !st.requiresHold()) return null;
		return switch st.kind {
			case Board: (target.get(Ingredient) != null) ? hintKey(holdKey("E"), "actions.chop") : null;
			case Sink:  (plate != null && plate.dirty)   ? hintKey(holdKey("E"), "actions.wash") : null;
			default: null;
		}
	}

	function fullHandsHints(world:World, cx:Int, cy:Int, hands:Hands):Array<ActionHint> {
		if (InteractQueries.findTrashAtCell(world, cx, cy) != null) {
			return [hintKey("E", "actions.trash")];
		}

		var held = hands.held;

		if (held != null && held.get(Plate) != null) {
			var target = InteractQueries.findCarryableAtCell(world, cx, cy);
			if (target != null) {
				if (target.get(Ingredient) != null) {
					var p = held.get(Plate);
					if (!p.isFull() && !p.hasStack()) return [hintKey("E", "actions.scoop")];
					return [];
				}
				if (target.get(Plate) != null) return [hintKey("E", "actions.stack")];
			}
		}

		if (held != null && held.get(Ingredient) != null) {
			var target = InteractQueries.findCarryableAtCell(world, cx, cy);
			if (target != null && target.get(Plate) != null) {
				var p = target.get(Plate);
				if (!p.isFull()) return [hintKey("E", "actions.onto_plate")];
				return [];
			}
		}

		var surf = InteractQueries.findSurfaceAtCell(world, cx, cy);
		if (surf != null) {
			var sc = surf.get(Surface);
			if (sc.occupantAt(cx, cy) == null) {
				var hints = [hintKey("E", "actions.place")];
				if (held != null) {
					var hp = held.get(Plate);
					if (hp != null && hp.contents.length > 0) hints.push(hintKey("Shift+E", "actions.drop_last"));
				}
				return hints;
			}
			return [];
		}
		return [hintKey(holdKey("E"), "actions.throw")];
	}

	static inline function hintKey(key:String, labelKey:String, ?args:PlaceholderArgs):ActionHint {
		return { key: key, label: I18n.t(labelKey, args), enabled: true, progress: 0 };
	}

	static function holdKey(key:String):String {
		var args:PlaceholderArgs = new haxe.DynamicAccess<String>();
		args.set("key", key);
		return I18n.t("actions.hold_prompt", args);
	}
}
