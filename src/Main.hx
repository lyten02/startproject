package;

import starter.AppBase;
import game.Game;

class Main extends AppBase {
	/** Stamp captured at entry point — used by debug overlay to measure startup ms. */
	public static var startupStamp:Float = 0;

	override function createGame():starter.IGame {
		return new Game();
	}

	static function main() {
		startupStamp = haxe.Timer.stamp();
		h3d.Engine.ANTIALIASING = 8;
		new Main();
	}
}
