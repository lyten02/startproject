package game.core;

import utest.Assert;
import utest.Test;

class TestThrowPhysics extends Test {
	function testChargeBelowMinClampsToMinSpeed() {
		Assert.floatEquals(ThrowPhysics.MIN_SPEED, ThrowPhysics.chargeToSpeed(0));
		Assert.floatEquals(ThrowPhysics.MIN_SPEED, ThrowPhysics.chargeToSpeed(0.1));
	}

	function testChargeAboveMaxClampsToMaxSpeed() {
		Assert.floatEquals(ThrowPhysics.MAX_SPEED, ThrowPhysics.chargeToSpeed(ThrowPhysics.MAX_CHARGE));
		Assert.floatEquals(ThrowPhysics.MAX_SPEED, ThrowPhysics.chargeToSpeed(10));
	}

	function testChargeIsMonotonic() {
		var prev = ThrowPhysics.chargeToSpeed(ThrowPhysics.MIN_CHARGE);
		var t = ThrowPhysics.MIN_CHARGE;
		while (t < ThrowPhysics.MAX_CHARGE) {
			t += 0.05;
			var s = ThrowPhysics.chargeToSpeed(t);
			Assert.isTrue(s >= prev);
			prev = s;
		}
	}

	function testStepAppliesGravityToVz() {
		var r = ThrowPhysics.step(0, 0, 0, 0, 0, 100, 0.1);
		Assert.floatEquals(100 - ThrowPhysics.GRAVITY * 0.1, r.vz);
	}

	function testStepLinearHorizontal() {
		var r = ThrowPhysics.step(10, 20, 0, 100, -50, 0, 0.5);
		Assert.floatEquals(60, r.x);
		Assert.floatEquals(-5, r.y);
	}

	function testHasLanded() {
		Assert.isTrue(ThrowPhysics.hasLanded(0, 0));
		Assert.isTrue(ThrowPhysics.hasLanded(-1, -100));
		Assert.isFalse(ThrowPhysics.hasLanded(5, 10));
		Assert.isFalse(ThrowPhysics.hasLanded(0.1, -1));
	}

	function testBounceInvertsAndDecays() {
		var r = ThrowPhysics.bounce(100);
		Assert.floatEquals(-100 * ThrowPhysics.RESTITUTION, r);
		Assert.floatEquals(100 * ThrowPhysics.RESTITUTION, ThrowPhysics.bounce(-100));
		Assert.floatEquals(0, ThrowPhysics.bounce(0));
	}

	function testKickConstantsAreSane() {
		Assert.isTrue(ThrowPhysics.KICK_FACTOR > 0 && ThrowPhysics.KICK_FACTOR < 1,
			'KICK_FACTOR must be in (0,1), got ${ThrowPhysics.KICK_FACTOR}');
		Assert.isTrue(ThrowPhysics.KICK_LAUNCH_VZ < ThrowPhysics.LAUNCH_VZ,
			'Kick pop must be weaker than a thrown arc');
		Assert.isTrue(ThrowPhysics.KICK_LAUNCH_VZ > 0);
	}

	function testBounceMonotoneEnergyLoss() {
		// |after| < |before| for any non-zero velocity (RESTITUTION < 1).
		var v = 500.0;
		for (i in 0...ThrowPhysics.MAX_BOUNCES) {
			var next = Math.abs(ThrowPhysics.bounce(v));
			Assert.isTrue(next < Math.abs(v));
			v = next;
		}
	}

	function testScaleAtGroundIsOne() {
		Assert.floatEquals(1, ThrowPhysics.scaleForZ(0));
		Assert.floatEquals(1, ThrowPhysics.scaleForZ(-5));
	}

	function testScaleAtPeakIsMax() {
		var s = ThrowPhysics.scaleForZ(ThrowPhysics.peakZ());
		Assert.floatEquals(1 + ThrowPhysics.SCALE_GAIN, s);
		// Beyond peak clamps (doesn't explode).
		Assert.floatEquals(1 + ThrowPhysics.SCALE_GAIN, ThrowPhysics.scaleForZ(ThrowPhysics.peakZ() * 10));
	}

	function testScaleMonotonicBetweenZeroAndPeak() {
		var prev = 1.0;
		var peak = ThrowPhysics.peakZ();
		var step = peak / 20;
		var z = step;
		while (z <= peak) {
			var s = ThrowPhysics.scaleForZ(z);
			Assert.isTrue(s >= prev);
			prev = s;
			z += step;
		}
	}

	function testClampToBoundsClampsBothAxes() {
		var r = ThrowPhysics.clampToBounds(-10, 500, 20, 20, 100, 100);
		Assert.floatEquals(0, r.x);
		Assert.floatEquals(80, r.y);
	}

	/**
	 * PROPERTY-BASED: random initial positions + random throw vectors.
	 * Invariant: after simulating until the projectile lands, the clamped
	 * final position is always within the world collision rectangle.
	 */
	function testThrowInvariantNeverEscapesWorld() {
		var seed = 0x2b3c4d;
		var worldW = 1920.0, worldH = 1088.0, itemW = 20.0, itemH = 20.0;

		for (i in 0...500) {
			seed = rng(seed);
			var startX:Float = (seed & 0xFFFF) % Std.int(worldW - itemW);
			seed = rng(seed);
			var startY:Float = (seed & 0xFFFF) % Std.int(worldH - itemH);
			seed = rng(seed);
			var angle  = ((seed & 0xFFFF) / 65535.0) * Math.PI * 2;
			seed = rng(seed);
			var speed  = ThrowPhysics.MIN_SPEED + ((seed & 0xFFFF) / 65535.0) * (ThrowPhysics.MAX_SPEED - ThrowPhysics.MIN_SPEED);

			var x:Float = startX, y:Float = startY, z:Float = 1.0;
			var vx = Math.cos(angle) * speed;
			var vy = Math.sin(angle) * speed;
			var vz = ThrowPhysics.LAUNCH_VZ;

			var steps = 0;
			while (!ThrowPhysics.hasLanded(z, vz) && steps < 2000) {
				var s = ThrowPhysics.step(x, y, z, vx, vy, vz, 1 / 60);
				x = s.x; y = s.y; z = s.z; vz = s.vz;
				steps++;
			}
			var c = ThrowPhysics.clampToBounds(x, y, itemW, itemH, worldW, worldH);
			Assert.isTrue(c.x >= 0 && c.x <= worldW - itemW,
				'seed=$seed iter=$i final x=${c.x} outside [0,${worldW - itemW}]');
			Assert.isTrue(c.y >= 0 && c.y <= worldH - itemH,
				'seed=$seed iter=$i final y=${c.y} outside [0,${worldH - itemH}]');
			Assert.isTrue(steps < 2000, 'seed=$seed iter=$i failed to land within 2000 steps');
		}
	}

	/** Deterministic LCG — stdlib Math.random() isn't seedable and flakes CI. */
	static inline function rng(s:Int):Int {
		return ((s * 1103515245 + 12345) & 0x7FFFFFFF);
	}
}
