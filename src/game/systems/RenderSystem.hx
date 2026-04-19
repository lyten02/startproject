package game.systems;

import game.core.ThrowPhysics;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.InFlight;
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
			// Flat-throw perspective: height z never lifts the sprite visually —
			// only modulates its scale, re-anchored to the AABB center so the item
			// doesn't drift toward its bottom-right corner as it pops.
			var fl  = e.get(InFlight);
			var scl = fl != null ? ThrowPhysics.scaleForZ(fl.z) : 1;
			var co  = e.get(Collider);
			var halfDx = co != null ? co.w * (scl - 1) * 0.5 : 0;
			var halfDy = co != null ? co.h * (scl - 1) * 0.5 : 0;
			sr.display.x = tr.pos.x - halfDx;
			sr.display.y = tr.pos.y - halfDy;
			sr.display.setScale(scl);
			// No rotation in flat-throw mode — top-left-pivoted rotation looks like
			// an arc drift (the AABB corners orbit the origin). Keep items upright.
			sr.display.rotation = 0;
		}
	}
}
