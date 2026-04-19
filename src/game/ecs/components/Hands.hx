package game.ecs.components;

import game.ecs.Entity;

/**
 * Player's hand slot. Tracks:
 *   - held item entity (null = empty)
 *   - charge time (seconds the action button has been held)
 */
class Hands implements Component {
	public var held:Entity;
	public var chargeSec:Float = 0;        // accumulated with game-time multiplier (for launch speed + visuals)
	public var pressSec:Float  = 0;         // accumulated with real dt (for tap-vs-throw decision)
	public var charging:Bool   = false;
	/** haxe.Timer.stamp of the last trash disposal — used for a 300 ms E-cooldown. */
	public var lastTrashStamp:Float = -1;

	public function new() {}
}
