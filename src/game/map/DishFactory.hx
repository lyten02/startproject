package game.map;

import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Dish;
import game.ecs.components.Dish.DishType;
import game.ecs.components.Plate.PlateSlot;
import game.ecs.components.SpriteRender;
import game.ecs.components.Transform;
import game.recipes.RecipeBook;

/**
 * Spawns a finished Dish as a carryable entity. Sprite path comes from the
 * loaded RecipeMeta.resultIconPath (recipes.json); DishFactory.dishAsset is
 * the compile-time fallback when meta is absent (e.g. pre-load test code).
 */
class DishFactory {
	public static inline var SIZE:Float = 20;

	public static function spawnDish(w:World, px:Float, py:Float, type:DishType, sourceSlots:Array<PlateSlot>):Entity {
		var meta = RecipeBook.findMeta(type);
		var path = meta != null && meta.resultIconPath != null ? meta.resultIconPath : "sprites/dishes/" + dishAsset(type);
		var e = w.create();
		e.add(new Transform(px, py));
		e.add(new Collider(SIZE, SIZE, false));
		e.add(new SpriteRender(path, SIZE));
		e.add(new Carryable());
		e.add(new Dish(type, sourceSlots));
		return e;
	}

	public static function dishAsset(type:DishType):String {
		return switch type {
			case Sandwich:           "sandwich";
			case Bruschetta:         "bruschetta";
			case ClassicBurger:      "classic_burger";
			case CheeseBurger:       "cheese_burger";
			case RoyalBurger:        "royal_burger";
			case DoubleCheeseburger: "double_cheeseburger";
			case TowerBurger:        "tower_burger";
		}
	}
}
