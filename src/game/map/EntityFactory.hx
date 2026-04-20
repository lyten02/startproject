package game.map;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.map.MapData.MapEntity;
import game.ecs.components.ShapeRender.ShapeKind;
import game.ecs.components.Collider;
import game.ecs.components.PlayerControlled;
import game.ecs.components.ShapeRender;
import game.ecs.components.Transform;
import game.ecs.components.Velocity;

/**
 * Spawns ECS entities from map data. Coordinate convention:
 *   - Grid (x, y) → pixel top-left of a cell (32×32 px).
 *   - Entities occupy (w, h) cells starting at that top-left.
 *   - Transform.pos = AABB top-left = grid top-left (consistent w/ ShapeFactory).
 */
class EntityFactory {
	public static inline var GRAY:Int = 0x888888;
	public static inline var RED:Int  = 0xFF0000;

	public static function spawnAll(world:World, map:MapData):Void {
		for (e in map.entities) spawn(world, e);
	}

	public static function spawn(world:World, e:MapEntity):Entity {
		var px = Grid.cellToPx(e.x);
		var py = Grid.cellToPx(e.y);
		var cw = (e.w != null ? e.w : 1) * Grid.CELL;
		var ch = (e.h != null ? e.h : 1) * Grid.CELL;
		var cr = (e.r != null ? e.r : 1) * Grid.CELL;  // half-diameter in pixels
		var tint = e.color != null ? e.color : GRAY;
		return switch e.type {
			case "player":   player(world, px, py);
			case "rect":     obstacle(world, px, py, cw, ch, Rect(cw, ch), tint);
			case "circle":   obstacle(world, px, py, cr * 2, cr * 2, Circle(cr), tint);
			case "triangle": obstacle(world, px, py, cw, ch, Triangle(cw * 0.5, ch * 0.5), tint);
			case "diamond":  obstacle(world, px, py, cw, ch, Diamond(cw * 0.5, ch * 0.5), tint);
			case "hexagon":  obstacle(world, px, py, cr * 2, cr * 2, Hexagon(cr), tint);
			default: throw 'EntityFactory: unknown type "${e.type}"';
		}
	}

	static function player(w:World, x:Float, y:Float):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Velocity());
		e.add(new Collider(Grid.CELL, Grid.CELL));
		e.add(new PlayerControlled(200));
		e.add(new ShapeRender(Rect(Grid.CELL, Grid.CELL), RED));
		return e;
	}

	static function obstacle(w:World, x:Float, y:Float, cw:Float, ch:Float, kind:ShapeKind, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(cw, ch));
		e.add(new ShapeRender(kind, color));
		return e;
	}
}
