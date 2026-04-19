package game.ecs.components;

import game.ecs.Entity;

/**
 * Singleton component holding the FIFO of active Order entities plus the
 * spawn timer. OrderSpawnSystem appends; OrderDeliverySystem removes on match.
 */
class OrderQueue implements Component {
	public var orders:Array<Entity> = [];
	public var maxSize(default, null):Int;
	public var spawnTimerSec:Float = 0;

	public function new(maxSize:Int) {
		this.maxSize = maxSize;
	}

	public inline function isFull():Bool return orders.length >= maxSize;
	public inline function length():Int  return orders.length;
}
