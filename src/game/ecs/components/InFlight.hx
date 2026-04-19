package game.ecs.components;

/**
 * Airborne item physics state. Position XY lives in Transform.
 * `z` is vertical offset (pixels, 0 = ground). `vz` positive = up.
 */
class InFlight implements Component {
	public var vx:Float;
	public var vy:Float;
	public var vz:Float;
	public var z:Float;
	public var spin:Float = 0;
	public var bounces:Int = 0;

	public function new(vx:Float, vy:Float, vz:Float, z:Float = 0) {
		this.vx = vx;
		this.vy = vy;
		this.vz = vz;
		this.z  = z;
	}
}
