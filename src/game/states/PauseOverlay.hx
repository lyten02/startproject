package game.states;

import game.render.SceneScaler;
import h2d.Bitmap;
import h2d.Object;
import h2d.Text;
import h2d.Tile;
import loc.text.reactive.ReactiveText;

/**
 * Full-screen semi-transparent dim + centred "PAUSE" label.
 * Doesn't own input — GameplayState toggles `visible` on `Pause` action.
 */
class PauseOverlay {
	public var visible(get, set):Bool;

	var root:Object;
	var dim:Bitmap;
	var labelBg:Bitmap;
	var label:Text;

	public function new(parent:Object, font:h2d.Font) {
		root = new Object(parent);
		dim  = new Bitmap(Tile.fromColor(0x000000, 1, 1, 0.3), root);

		labelBg = new Bitmap(Tile.fromColor(0x000000, 1, 1, 0.75), root);
		label   = new ReactiveText(font, "ui.pause_label", root);
		label.smooth = true;
		label.textAlign = Center;
		label.textColor = 0xFFD166;
		root.visible = false;
	}

	public function position(scaler:SceneScaler):Void {
		dim.scaleX = scaler.vW;
		dim.scaleY = scaler.vH;

		var lw = label.textWidth  + 40;
		var lh = label.textHeight + 20;
		var lx = (scaler.vW - lw) * 0.5;
		var ly = (scaler.vH - lh) * 0.5;
		labelBg.x = lx;
		labelBg.y = ly;
		labelBg.scaleX = lw;
		labelBg.scaleY = lh;
		label.x = scaler.vW * 0.5;
		label.y = ly + 10;

		if (root.parent != null) root.parent.addChild(root); // keep on top
	}

	public function dispose():Void {
		if (root != null) root.remove();
	}

	inline function get_visible():Bool return root.visible;
	inline function set_visible(v:Bool):Bool return root.visible = v;
}
