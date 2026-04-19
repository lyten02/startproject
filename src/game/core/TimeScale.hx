package game.core;

/**
 * Discrete game-time multiplier. Steps through a fixed list of speeds so a
 * single key-press moves exactly one tier (no runaway from 1x to 10x).
 * Pure — no engine deps, trivial to unit-test.
 */
class TimeScale {
	public static final STEPS:Array<Float> = [0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 5.0, 10.0];
	static inline var DEFAULT_INDEX:Int = 3; // 1.0x

	public var index(default, null):Int = DEFAULT_INDEX;

	public function new() {}

	public inline function value():Float {
		return STEPS[index];
	}

	public function up():Bool {
		if (index >= STEPS.length - 1) return false;
		index++;
		return true;
	}

	public function down():Bool {
		if (index <= 0) return false;
		index--;
		return true;
	}

	public inline function isMin():Bool return index == 0;
	public inline function isMax():Bool return index == STEPS.length - 1;

	public inline function label():String return labelFor(value()) + (isMax() ? " MAX" : "");

	public static function labelFor(v:Float):String {
		var s = Std.string(Math.round(v * 100) / 100);
		if (s.indexOf(".") < 0) s += ".0";
		return s + "x";
	}
}
