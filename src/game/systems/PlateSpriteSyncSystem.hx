package game.systems;

import game.ecs.World;
import game.ecs.components.Plate;
import game.ecs.components.SpriteRender;
import game.map.EntityFactory;

/**
 * Syncs the plate's SpriteRender.resPath to its `dirty` flag each frame.
 * SpriteRenderSystem reloads the tile on resPath change, so toggling is cheap.
 */
class PlateSpriteSyncSystem implements ISystem {
	public function new() {}

	public function update(world:World, dt:Float):Void {
		for (e in world.query(Plate)) {
			var sr = e.get(SpriteRender);
			if (sr == null) continue;
			var want = e.get(Plate).dirty ? EntityFactory.PLATE_SPRITE_DIRTY : EntityFactory.PLATE_SPRITE_CLEAN;
			if (sr.resPath != want) sr.resPath = want;
		}
	}
}
