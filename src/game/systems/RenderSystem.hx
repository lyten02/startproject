package game.systems;

import game.ecs.World;
import game.ecs.components.ShapeRender;
import game.ecs.components.Transform;
import game.render.ShapeFactory;

/**
 * Syncs ECS state to Heaps scene. Creates h2d.Object on first seen ShapeRender,
 * then updates position each frame from Transform.
 */
class RenderSystem implements ISystem {
	var root:h2d.Object;

	public function new(root:h2d.Object) {
		this.root = root;
	}

	public function update(world:World, dt:Float):Void {
		for (e in world.query(ShapeRender)) {
			var sr = e.get(ShapeRender);
			var tr = e.get(Transform);
			if (tr == null) continue;

			if (sr.display == null) {
				sr.display = ShapeFactory.build(sr.kind, sr.color, root);
			}
			sr.display.x = tr.pos.x;
			sr.display.y = tr.pos.y;
			sr.display.setScale(1);
			sr.display.rotation = 0;
		}
	}
}
