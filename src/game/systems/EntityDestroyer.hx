package game.systems;

import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Label;
import game.ecs.components.ShapeRender;
import game.ecs.components.SpriteRender;

/** Destroys an entity: detaches its h2d views and removes it from World. */
class EntityDestroyer {
	public static function destroy(world:World, e:Entity):Void {
		var sr = e.get(ShapeRender);
		if (sr != null && sr.display != null) sr.display.remove();
		var sp = e.get(SpriteRender);
		if (sp != null && sp.display != null) sp.display.remove();
		var lb = e.get(Label);
		if (lb != null && lb.display != null) lb.display.remove();
		world.destroy(e);
	}
}
