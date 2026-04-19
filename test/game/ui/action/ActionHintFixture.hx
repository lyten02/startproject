package game.ui.action;

import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Facing;
import game.ecs.components.Hands;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;

/** Shared ECS setup helpers for ActionHint* tests. */
class ActionHintFixture {
	public static inline var CELL = 32;

	/** Player at cell (5,5) facing +X → facing cell = (6,5). */
	public static function makePlayer(w:World):Entity {
		var p = w.create();
		p.add(new Transform(5 * CELL, 5 * CELL));
		p.add(new Collider(CELL, CELL));
		p.add(new Facing(1, 0));
		p.add(new PlayerControlled());
		p.add(new Hands());
		return p;
	}

	public static function makeItem(w:World, cx:Int, cy:Int):Entity {
		var e = w.create();
		e.add(new Transform(cx * CELL, cy * CELL));
		e.add(new Collider(CELL, CELL));
		e.add(new Carryable());
		return e;
	}
}
