package game.ecs.components;

/**
 * Renderable bitmap sprite. Set by SpriteRenderSystem; `res` is the resource
 * path (e.g. "sprites/ingredients/tomato"), resolved lazily at first draw.
 */
class SpriteRender implements Component {
	public var resPath:String;
	public var size:Float;          // target on-screen AABB side in px
	public var tint:Int = 0xFFFFFF; // RGB multiply; 0xFFFFFF = no tint
	public var display:h2d.Bitmap;  // populated by SpriteRenderSystem
	public var loadedPath:String;   // last path baked into `display.tile` — resync on mismatch

	public function new(resPath:String, size:Float) {
		this.resPath = resPath;
		this.size    = size;
	}
}
