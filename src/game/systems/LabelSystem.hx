package game.systems;

import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Label;
import game.ecs.components.Transform;
import h2d.Font;
import h2d.Text;
import loc.base.LocEvent;
import loc.text.I18n;

/**
 * Spawns/updates h2d.Text tags above every entity carrying a Label.
 * Label sits centered on the entity's top edge, in world-space (child of `root`),
 * so the camera scroll applies identically. Subscribes to I18n.signal so that
 * language changes propagate to every live label in a single pass.
 */
class LabelSystem implements ISystem {
	static inline var OFFSET_Y:Float = 6;

	var root:h2d.Object;
	var font:Font;
	var world:World;
	var unlisten:Void->Void;

	public function new(root:h2d.Object, font:Font) {
		this.root = root;
		this.font = font;
		unlisten = I18n.signal.listen(onLocEvent);
	}

	public function update(world:World, dt:Float):Void {
		this.world = world;
		for (e in world.query(Label)) {
			var lb = e.get(Label);
			var tr = e.get(Transform);
			if (tr == null) continue;

			if (lb.display == null) {
				var t = new Text(font, root);
				t.text      = I18n.t(lb.key);
				t.textColor = lb.color;
				t.textAlign = Center;
				lb.display  = t;
			}

			var col = e.get(Collider);
			var cx  = tr.pos.x + (col != null ? col.w * 0.5 : 0);
			var top = tr.pos.y;
			lb.display.x = cx;
			lb.display.y = top - lb.display.textHeight - OFFSET_Y;
		}
	}

	public function dispose():Void {
		if (unlisten != null) { unlisten(); unlisten = null; }
	}

	function onLocEvent(e:LocEvent):Void {
		switch e {
			case Change(_), Loaded(_): refreshAll();
			case MissingKey(_, _):
		}
	}

	function refreshAll():Void {
		if (world == null) return;
		for (e in world.query(Label)) {
			var lb = e.get(Label);
			if (lb.display != null) lb.display.text = I18n.t(lb.key);
		}
	}
}
