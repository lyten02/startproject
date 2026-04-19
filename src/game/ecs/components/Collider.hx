package game.ecs.components;

/** AABB collision box (size only; position from Transform). */
class Collider implements Component {
	public var w:Float;
	public var h:Float;
	public var solid:Bool;

	public function new(w:Float, h:Float, solid:Bool = true) {
		this.w = w;
		this.h = h;
		this.solid = solid;
	}
}
