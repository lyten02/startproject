package game.systems;

import game.core.ThrowPhysics;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Hands;
import game.ecs.components.Plate;
import game.ecs.components.PlayerControlled;
import game.input.GameAction;
import game.input.InputBindings;

/**
 * Converts Interact input into pickup/place/throw actions via InteractActions.
 * Tap (<MIN_CHARGE) = pickup or place; hold+release = throw.
 * Charging feedback is sent to ActionBar while the button is held.
 */
class InteractSystem implements ISystem {
	/** Multiplier applied to chargeSec accumulation — 1 in release, = TimeScale in debug. */
	public var chargeMultiplier:Float = 1;

	var input:InputBindings;
	var chordSuppress:Map<Int, Bool> = new Map();

	public function new(input:InputBindings) {
		this.input = input;
	}

	public function update(world:World, dt:Float):Void {
		for (e in world.query(PlayerControlled)) {
			var hands = e.get(Hands);
			if (hands == null) continue;
			tickPlayer(world, e, hands, dt);
		}
	}

	function tickPlayer(world:World, player:Entity, hands:Hands, dt:Float):Void {
		var down = input.isDown(GameAction.Interact);
		if (!down) chordSuppress.remove(player.id);

		if (down && !hands.charging && chordSuppress.get(player.id) != true) {
			if (input.shiftDown() && tryShiftChord(world, player, hands)) {
				chordSuppress.set(player.id, true);
				return;
			}
			hands.charging = true;
			hands.chargeSec = 0;
			hands.pressSec  = 0;
		} else if (down && hands.charging) {
			hands.pressSec  += dt;
			hands.chargeSec += dt * chargeMultiplier;
			if (hands.pressSec >= ThrowPhysics.MIN_CHARGE && hands.held != null) {
				InteractActions.notify(player, 'Charging ${chargePct(hands.chargeSec)}%', 0.5, 0x8EC5FF);
			}
		} else if (!down && hands.charging) {
			resolveRelease(world, player, hands);
			hands.charging = false;
			hands.chargeSec = 0;
			hands.pressSec  = 0;
		}
	}

	function resolveRelease(world:World, player:Entity, hands:Hands):Void {
		if (hands.pressSec >= ThrowPhysics.MIN_CHARGE) {
			if (hands.held != null) InteractActions.doThrow(world, player, hands);
			return;
		}
		if (hands.held == null) InteractActions.tryPickup(world, player, hands);
		else InteractActions.tryPlace(world, player, hands);
	}

	static function tryShiftChord(world:World, player:Entity, hands:Hands):Bool {
		if (hands.held == null) {
			if (!canTakeFromPlate(world, player, hands)) return false;
			PlateActions.takeFromPlate(world, player, hands);
			return true;
		}
		return PlateActions.dropLastFromHeldPlate(world, player, hands);
	}

	static function canTakeFromPlate(world:World, player:Entity, hands:Hands):Bool {
		var cell = InteractQueries.facingCell(player);
		var target = InteractQueries.findCarryableAtCell(world, cell.x, cell.y);
		if (target == null) return false;
		var p = target.get(Plate);
		return p != null && (p.hasStack() || p.contents.length > 0);
	}

	static inline function chargePct(chargeSec:Float):Int {
		var range = ThrowPhysics.MAX_CHARGE - ThrowPhysics.MIN_CHARGE;
		var t = range <= 0 ? 1 : (chargeSec - ThrowPhysics.MIN_CHARGE) / range;
		if (t < 0) t = 0;
		if (t > 1) t = 1;
		return Math.round(t * 100);
	}
}
