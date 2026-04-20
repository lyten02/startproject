package game.input;

import hxd.Key;
import dn.heaps.input.Controller;
import dn.heaps.input.ControllerAccess;
import dn.heaps.input.Controller.PadButton;

/**
 * Wraps `dn.heaps.input.Controller` (from deepnightLibs) with a game-specific action set.
 *
 * Maps keyboard + gamepad inputs to strongly-typed `GameAction` values.
 * Each direction is a discrete action bound to multiple keys (arrows + WASD + dpad).
 */
class InputBindings {
	public var access(default, null):ControllerAccess<GameAction>;

	var controller:Controller<GameAction>;

	public function new() {
		controller = Controller.createFromAbstractEnum(GameAction);

		// Directional actions — each bound to arrows, WASD, and gamepad dpad.
		controller.bindKeyboard(GameAction.MoveLeft,  [Key.LEFT,  Key.A]);
		controller.bindKeyboard(GameAction.MoveRight, [Key.RIGHT, Key.D]);
		controller.bindKeyboard(GameAction.MoveUp,    [Key.UP,    Key.W]);
		controller.bindKeyboard(GameAction.MoveDown,  [Key.DOWN,  Key.S]);

		controller.bindPad(GameAction.MoveLeft,  PadButton.DPAD_LEFT);
		controller.bindPad(GameAction.MoveRight, PadButton.DPAD_RIGHT);
		controller.bindPad(GameAction.MoveUp,    PadButton.DPAD_UP);
		controller.bindPad(GameAction.MoveDown,  PadButton.DPAD_DOWN);

		// Debug overlay toggle (F2; also backtick for laptops without F-keys).
		controller.bindKeyboard(GameAction.ToggleDebug, [Key.F2, Key.QWERTY_TILDE]);

		// Debug time scale (+ / -). Covers both main-row and numpad.
		controller.bindKeyboard(GameAction.DebugSpeedUp,   [Key.QWERTY_EQUALS, Key.NUMPAD_ADD]);
		controller.bindKeyboard(GameAction.DebugSpeedDown, [Key.QWERTY_MINUS, Key.NUMPAD_SUB]);

		// Debug camera zoom reset (wheel delta is handled directly via hxd.Event in GameplayState).
		controller.bindKeyboard(GameAction.DebugResetZoom, [Key.HOME]);

		access = controller.createAccess();
	}

	public function update(dt:Float):Void {
		// Controller polls hxd.Key/hxd.Pad live — nothing to tick manually.
	}

	public function dispose():Void {
		if (access != null) {
			access.dispose();
			access = null;
		}
	}

	public inline function isDown(action:GameAction):Bool {
		return access.isDown(action);
	}

	public inline function wasPressed(action:GameAction):Bool {
		return access.isPressed(action);
	}

	/** Combined horizontal movement vector derived from discrete left/right actions. */
	public inline function moveX():Float {
		return (isDown(GameAction.MoveRight) ? 1.0 : 0.0) - (isDown(GameAction.MoveLeft) ? 1.0 : 0.0);
	}

	/** Combined vertical movement vector (positive = down in 2D, forward in 3D). */
	public inline function moveY():Float {
		return (isDown(GameAction.MoveDown) ? 1.0 : 0.0) - (isDown(GameAction.MoveUp) ? 1.0 : 0.0);
	}
}
