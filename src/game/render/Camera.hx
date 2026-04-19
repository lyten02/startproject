package game.render;

/**
 * Scrolling camera. Centers on a target point and clamps so the view
 * never shows outside the world rectangle.
 *
 * Debug zoom (wheel-driven) lives here under `#if debug`; release builds
 * inline `zoom` as `1` so every callsite optimises down to the no-zoom path.
 */
class Camera {
	public var x(default, null):Float = 0;
	public var y(default, null):Float = 0;
	public var worldW:Float = 0;
	public var worldH:Float = 0;

	public static inline var MIN_ZOOM:Float     = 0.5;
	public static inline var MAX_ZOOM:Float     = 2.5;
	public static inline var DEFAULT_ZOOM:Float = 1.75;
	public static inline var ZOOM_STEP:Float    = 0.1;
	public static inline var LERP_TAU:Float     = 0.1;

	/** Release builds never mutate this; it stays at DEFAULT_ZOOM. */
	public var zoom:Float = DEFAULT_ZOOM;

	#if debug
	public var targetZoom:Float = DEFAULT_ZOOM;

	public inline function zoomBy(delta:Float):Void {
		targetZoom = clamp(targetZoom + delta, MIN_ZOOM, MAX_ZOOM);
	}

	public inline function resetZoom():Void {
		targetZoom = DEFAULT_ZOOM;
	}

	public function tick(dt:Float):Void {
		var t = dt / LERP_TAU;
		if (t > 1) t = 1;
		zoom += (targetZoom - zoom) * t;
	}

	static inline function clamp(v:Float, lo:Float, hi:Float):Float {
		return v < lo ? lo : (v > hi ? hi : v);
	}
	#end

	public function new() {
		#if debug
		zoom = DEFAULT_ZOOM;
		#end
	}

	/**
	 * Center view of size (viewW, viewH) on (targetX, targetY), clamped to world.
	 * `viewW`/`viewH` are screen pixels; at non-1 zoom the effective world view
	 * shrinks by `1/zoom`, so clamping is done against the scaled view.
	 */
	public function focus(targetX:Float, targetY:Float, viewW:Float, viewH:Float):Void {
		var vw = viewW / zoom;
		var vh = viewH / zoom;
		var cx = targetX - vw * 0.5;
		var cy = targetY - vh * 0.5;

		var maxX = worldW - vw;
		var maxY = worldH - vh;
		if (maxX < 0) maxX = 0;
		if (maxY < 0) maxY = 0;

		if (cx < 0) cx = 0; else if (cx > maxX) cx = maxX;
		if (cy < 0) cy = 0; else if (cy > maxY) cy = maxY;

		x = cx;
		y = cy;
	}
}
