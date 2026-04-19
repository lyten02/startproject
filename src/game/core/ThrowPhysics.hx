package game.core;

/**
 * Pure throw math — no Heaps deps. Parabolic trajectory: horizontal velocity
 * constant, vertical velocity decays under gravity until z hits the floor.
 *
 * Tuning constants live here so tests and systems agree on behaviour.
 */
class ThrowPhysics {
	public static inline var GRAVITY:Float      = 1800;  // px/s²
	public static inline var MIN_CHARGE:Float   = 0.2;   // sec, tap threshold
	public static inline var MAX_CHARGE:Float   = 1.5;   // sec, clamped upward
	public static inline var MIN_SPEED:Float    = 280;   // px/s at MIN_CHARGE
	public static inline var MAX_SPEED:Float    = 900;   // px/s at MAX_CHARGE (~8 cells)
	public static inline var LAUNCH_VZ:Float    = 380;   // upward kick, px/s
	public static inline var SCALE_GAIN:Float   = 0.4;   // visual pop at apex (1.0 → 1.4)
	public static inline var RESTITUTION:Float  = 0.55;  // speed retained along the reflected axis
	public static inline var MAX_BOUNCES:Int    = 4;     // hard cap — energy has fully dissipated
	public static inline var STALL_SPEED:Float  = 60;    // px/s; below this after a bounce → land
	public static inline var KICK_FACTOR:Float  = 0.6;   // momentum transferred to a plate the flying item hits
	public static inline var KICK_LAUNCH_VZ:Float = 120; // small arc given to the kicked plate

	/** Map held time to launch speed, clamped into [MIN_SPEED, MAX_SPEED]. */
	public static function chargeToSpeed(holdSec:Float):Float {
		if (holdSec <= MIN_CHARGE) return MIN_SPEED;
		if (holdSec >= MAX_CHARGE) return MAX_SPEED;
		var t = (holdSec - MIN_CHARGE) / (MAX_CHARGE - MIN_CHARGE);
		return MIN_SPEED + t * (MAX_SPEED - MIN_SPEED);
	}

	/** One integration step. Mutates in-place via return tuple. */
	public static function step(
		x:Float, y:Float, z:Float,
		vx:Float, vy:Float, vz:Float,
		dt:Float
	):{x:Float, y:Float, z:Float, vz:Float} {
		return {
			x:  x + vx * dt,
			y:  y + vy * dt,
			z:  z + vz * dt,
			vz: vz - GRAVITY * dt,
		};
	}

	/** True when item has returned to ground after being airborne. */
	public static inline function hasLanded(z:Float, vz:Float):Bool {
		return z <= 0 && vz <= 0;
	}

	/** Reflect a single-axis velocity component with restitution loss. */
	public static inline function bounce(v:Float):Float {
		return -v * RESTITUTION;
	}

	/**
	 * Peak z reached by a projectile launched with LAUNCH_VZ under GRAVITY.
	 * `z_peak = vz0² / (2g)` — used to normalize the visual scale curve.
	 */
	public static inline function peakZ():Float {
		return (LAUNCH_VZ * LAUNCH_VZ) / (2 * GRAVITY);
	}

	/**
	 * Map current z to a render-space scale multiplier.
	 * scale(0) = 1.0, scale(peakZ) = 1 + SCALE_GAIN, clamped.
	 * No visual vertical offset — height shows as size only (flat-throw perspective).
	 */
	public static function scaleForZ(z:Float):Float {
		if (z <= 0) return 1;
		var peak = peakZ();
		var t = z >= peak ? 1 : z / peak;
		return 1 + t * SCALE_GAIN;
	}

	/** Clamp final resting position to rectangular world bounds. */
	public static function clampToBounds(x:Float, y:Float, w:Float, h:Float, worldW:Float, worldH:Float):{x:Float, y:Float} {
		var maxX = worldW - w;
		var maxY = worldH - h;
		if (maxX < 0) maxX = 0;
		if (maxY < 0) maxY = 0;
		return {
			x: x < 0 ? 0 : (x > maxX ? maxX : x),
			y: y < 0 ? 0 : (y > maxY ? maxY : y),
		};
	}
}
