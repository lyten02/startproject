package game.systems;

import game.ecs.World;
import game.ecs.components.SpriteRender;
import game.ecs.components.Transform;

/** Mirrors RenderSystem for bitmap sprites. One h2d.Bitmap per SpriteRender. */
class SpriteRenderSystem implements ISystem {
	var root:h2d.Object;

	public function new(root:h2d.Object) {
		this.root = root;
	}

	public function update(world:World, dt:Float):Void {
		for (e in world.query(SpriteRender)) {
			var sr = e.get(SpriteRender);
			var tr = e.get(Transform);
			if (tr == null) continue;

			if (sr.display == null) {
				var tile = hxd.Res.load(sr.resPath + ".png").toImage().toTile();
				sr.display = new h2d.Bitmap(tile, root);
				sr.loadedPath = sr.resPath;
			} else if (sr.resPath != sr.loadedPath) {
				sr.display.tile = hxd.Res.load(sr.resPath + ".png").toImage().toTile();
				sr.loadedPath = sr.resPath;
			}
			var tile = sr.display.tile;
			var tw = tile != null && tile.width > 0 ? tile.width : sr.size;
			sr.display.x = tr.pos.x;
			sr.display.y = tr.pos.y;
			sr.display.setScale(sr.size / tw);

			var r = ((sr.tint >> 16) & 0xFF) / 255;
			var g = ((sr.tint >> 8)  & 0xFF) / 255;
			var b = ( sr.tint        & 0xFF) / 255;
			sr.display.color.set(r, g, b, 1);
		}
	}
}
