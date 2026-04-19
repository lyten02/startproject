package game.ecs.components;

import game.ecs.components.Dish.DishType;

/**
 * Active customer order. Lives as its own entity; `OrderQueue.orders` holds
 * a FIFO reference. Patience ticks down with scaled dt via OrderPatienceSystem
 * (pauses + speed 0.25x..10x already factored in).
 */
class Order implements Component {
	public var dishType(default, null):DishType;
	public var maxPatienceSec(default, null):Float;
	public var patienceSec:Float;
	public var reward(default, null):Int;
	public var ageSec:Float = 0;

	public function new(dishType:DishType, patienceSec:Float, reward:Int) {
		this.dishType       = dishType;
		this.maxPatienceSec = patienceSec;
		this.patienceSec    = patienceSec;
		this.reward         = reward;
	}

	public inline function patienceRatio():Float {
		return maxPatienceSec <= 0 ? 0 : patienceSec / maxPatienceSec;
	}
}
