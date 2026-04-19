package game.render;

/**
 * Computes uniform scale to fit virtual `refH` into actual canvas height.
 * Virtual width varies with aspect ratio (wider on ultra-wide screens).
 */
class SceneScaler {
	public var refH:Float;
	public var scale(default, null):Float = 1;
	public var vW(default, null):Float    = 0;
	public var vH(default, null):Float    = 0;

	public function new(refH:Float = 1080) {
		this.refH = refH;
	}

	public function sync(canvasW:Float, canvasH:Float):Void {
		scale = canvasH > 0 ? canvasH / refH : 1;
		vH    = refH;
		vW    = scale > 0 ? canvasW / scale : canvasW;
	}
}
