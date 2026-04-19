package game.map;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.map.MapData.MapEntity;
import game.ecs.components.ShapeRender.ShapeKind;
import game.ecs.components.ActionFeedback;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Dispenser;
import game.ecs.components.Facing;
import game.ecs.components.Hands;
import game.ecs.components.Ingredient;
import game.ecs.components.Label;
import game.ecs.components.SpriteRender;
import game.ecs.components.Plate;
import game.ecs.components.PlateStand;
import game.recipes.IngredientCatalog;
import game.ecs.components.PlayerControlled;
import game.ecs.components.ShapeRender;
import game.ecs.components.ServeWindow;
import game.ecs.components.SinkQueue;
import game.ecs.components.Station;
import game.ecs.components.Surface;
import game.ecs.components.Transform;
import game.ecs.components.Trash;
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
		var ent = switch e.type {
			case "player":   player(world, px, py);
			case "rect":     obstacle(world, px, py, cw, ch, Rect(cw, ch), tint);
			case "circle":   obstacle(world, px, py, cr * 2, cr * 2, Circle(cr), tint);
			case "triangle": obstacle(world, px, py, cw, ch, Triangle(cw * 0.5, ch * 0.5), tint);
			case "diamond":  obstacle(world, px, py, cw, ch, Diamond(cw * 0.5, ch * 0.5), tint);
			case "hexagon":  obstacle(world, px, py, cr * 2, cr * 2, Hexagon(cr), tint);
			case "plate":    plate(world, px, py, tint);
			case "ingredient-dispenser": ingredientDispenser(world, px, py, cr * 2, tint);
			default: throw 'EntityFactory: unknown type "${e.type}"';
		}
		if (e.label != null && e.label != "") ent.add(new Label(e.label));
		if (e.surface == true) ent.add(new Surface());
		if (e.stock != null)   ent.add(new Dispenser(e.stock, e.ingredient));
		if (e.trash == true) {
			ent.add(new Trash());
			ent.remove(ShapeRender);
			var side = cw < ch ? cw : ch;
			ent.add(new SpriteRender("sprites/stations/trash", side * 0.85));
		}
		if (e.station != null && e.station != "") {
			var k = stationFromId(e.station);
			ent.add(new Station(k));
			ent.add(new SpriteRender("sprites/stations/" + e.station, Grid.CELL * 0.6));
			if (k == Sink) ent.add(new SinkQueue());
		}
		if (e.stand == true) ent.add(new PlateStand());
		if (e.serve == true) ent.add(new ServeWindow());
		return ent;
	}

	static inline var PLATE_RADIUS:Float = 10;
	public static inline var PLATE_SPRITE_CLEAN:String = "sprites/plates/clean";
	public static inline var PLATE_SPRITE_DIRTY:String = "sprites/plates/dirty";

	static function plate(w:World, x:Float, y:Float, _:Int):Entity {
		return spawnPlate(w, x + Grid.CELL * 0.5 - PLATE_RADIUS, y + Grid.CELL * 0.5 - PLATE_RADIUS);
	}

	/** Runtime spawn for Dispenser. `px,py` — top-left of item AABB (pixels). */
	public static function spawnPlate(w:World, px:Float, py:Float):Entity {
		var e = w.create();
		var r = PLATE_RADIUS;
		e.add(new Transform(px, py));
		e.add(new Collider(r * 2, r * 2, false));
		e.add(new SpriteRender(PLATE_SPRITE_CLEAN, r * 2));
		e.add(new Carryable());
		e.add(new Plate());
		return e;
	}

	static function player(w:World, x:Float, y:Float):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Velocity());
		e.add(new Collider(Grid.CELL, Grid.CELL));
		e.add(new PlayerControlled(200));
		e.add(new Facing(0, 1));
		e.add(new Hands());
		e.add(new ActionFeedback());
		e.add(new ShapeRender(Rect(Grid.CELL, Grid.CELL), RED));
		return e;
	}

	static inline var INGREDIENT_SIZE:Float = 20;

	static function ingredientDispenser(w:World, x:Float, y:Float, side:Float, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(side, side));
		e.add(new ShapeRender(Rect(side, side), color));
		e.add(new Surface());
		return e;
	}

	/** Runtime spawn used by dispensers (InteractSystem) to create an ingredient at (px, py). */
	public static function spawnIngredient(w:World, px:Float, py:Float, type:IngredientType):Entity {
		var meta = IngredientCatalog.get(type);
		var sprite  = meta != null ? meta.iconPath     : "sprites/ingredients/" + ingredientAsset(type);
		var maxFresh = meta != null ? meta.maxFreshness : IngredientCatalog.DEFAULT_FRESHNESS;
		var e = w.create();
		e.add(new Transform(px, py));
		e.add(new Collider(INGREDIENT_SIZE, INGREDIENT_SIZE, false));
		e.add(new SpriteRender(sprite, INGREDIENT_SIZE));
		e.add(new Carryable());
		e.add(new Ingredient(type, maxFresh));
		return e;
	}

	public static function stationFromId(id:String):StationKind {
		return switch id.toLowerCase() {
			case "pan":   Pan;
			case "pot":   Pot;
			case "board": Board;
			case "sink":  Sink;
			default: throw 'EntityFactory: unknown station "$id"';
		}
	}

	public static function ingredientFromId(id:String):IngredientType {
		return switch id.toLowerCase() {
			case "bread":    Bread;
			case "meat":     Meat;
			case "cheese":   Cheese;
			case "tomato":   Tomato;
			case "lettuce":  Lettuce;
			case "onion":    Onion;
			case "cucumber": Cucumber;
			default: throw 'EntityFactory: unknown ingredient "$id"';
		}
	}

	public static function ingredientAsset(type:IngredientType):String {
		return switch type {
			case Bread:    "bread";
			case Meat:     "meat";
			case Cheese:   "cheese";
			case Tomato:   "tomato";
			case Lettuce:  "lettuce";
			case Onion:    "onion";
			case Cucumber: "cucumber";
		}
	}

	static function obstacle(w:World, x:Float, y:Float, cw:Float, ch:Float, kind:ShapeKind, color:Int):Entity {
		var e = w.create();
		e.add(new Transform(x, y));
		e.add(new Collider(cw, ch));
		e.add(new ShapeRender(kind, color));
		return e;
	}
}
