package game.ecs.components;

/** Renderable shape descriptor. Visual only; ShapeFactory draws it. */
enum ShapeKind {
	Rect(w:Float, h:Float);
	Circle(radius:Float);
	Triangle(halfW:Float, halfH:Float);
	Diamond(halfW:Float, halfH:Float);
	Hexagon(radius:Float);
}

class ShapeRender implements Component {
	public var kind:ShapeKind;
	public var color:Int;
	public var display:h2d.Object;  // set by RenderSystem when spawned

	public function new(kind:ShapeKind, color:Int) {
		this.kind  = kind;
		this.color = color;
	}
}
