package game.ecs.components;

import game.ecs.Entity;

/** FIFO stack of plates sitting in / on a Sink station. */
class SinkQueue implements Component {
	public static inline var MAX:Int = 6;

	public var plates:Array<Entity> = [];

	public function new() {}

	public inline function isFull():Bool return plates.length >= MAX;
	public inline function push(p:Entity):Void plates.push(p);
	public inline function bottom():Entity return plates.length > 0 ? plates[0] : null;
}
