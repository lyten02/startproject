package game.ecs.components;

/**
 * Singleton session score. Incremented by OrderDeliverySystem on success
 * and OrderPatienceSystem on expiry. ScoreHudPresenter reads it each frame.
 */
class GameStats implements Component {
	public var served:Int = 0;
	public var failed:Int = 0;
	public var money:Int  = 0;

	public function new() {}

	public inline function recordServed(reward:Int):Void {
		served++;
		money += reward;
	}

	public inline function recordFailed():Void {
		failed++;
	}
}
