package game.ecs.components;

import game.ecs.components.Ingredient.IngredientState;

enum StationKind {
	Pan;    // passive cook: Raw → Cooked → Burnt
	Pot;    // passive boil: Raw → Cooked → Burnt (longer)
	Board;  // active chop (manual): Raw → Chopped
	Sink;   // active wash (manual): dirty plate → clean
}

/**
 * Processing station marker. Timings are per-kind constants used by
 * CookingSystem to drive state transitions on ingredients sitting in its
 * surface cells. Board/Sink currently only mark the role — manual interaction
 * will be wired in a later phase.
 */
class Station implements Component {
	public var kind(default, null):StationKind;

	public function new(kind:StationKind) {
		this.kind = kind;
	}

	public inline function cookSec():Float {
		return switch kind {
			case Pan:   5;
			case Pot:   8;
			case Board: 2;
			case Sink:  2;
		}
	}

	/** Extra seconds past cookSec() before the ingredient burns / spoils. */
	public inline function burnSec():Float {
		return switch kind {
			case Pan:   3;
			case Pot:   5;
			case Board: 999; // chopping can't burn
			case Sink:  999;
		}
	}

	public inline function successState():IngredientState {
		return switch kind {
			case Pan:   Cooked; // fried
			case Pot:   Boiled; // boiled / stewed
			case Board: Chopped;
			case Sink:  Raw; // no-op for now
		}
	}

	/** Pan/Pot cook on their own; Board/Sink need the player to hold E. */
	public inline function requiresHold():Bool {
		return switch kind {
			case Pan | Pot:   false;
			case Board | Sink: true;
		}
	}
}
