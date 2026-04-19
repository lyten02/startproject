package game.i18n;

import game.ecs.components.Dish.DishType;
import game.ecs.components.Ingredient.IngredientType;
import game.ecs.components.Ingredient.IngredientState;
import game.recipes.IngredientCatalog;
import game.recipes.RecipeBook;
import loc.text.I18n;

/**
 * Game-specific i18n resolvers that translate ECS enums into dotted i18n keys.
 * Keeps enum → key mapping in a single place so JSON files and Haxe enums can
 * evolve independently. JSON convention: `snake_case` keys for multi-word names.
 */
class GameI18n {
	public static inline function recipeName(id:DishType):String {
		var meta = RecipeBook.findMeta(id);
		return I18n.t(meta != null ? meta.i18nKey : "recipes." + camelToSnake(Std.string(id)));
	}

	public static inline function ingredientName(type:IngredientType):String {
		var meta = IngredientCatalog.get(type);
		return I18n.t(meta != null ? meta.i18nKey : "ingredients." + Std.string(type).toLowerCase());
	}

	/** Resolve a localized ingredient name from the dispenser string id ("bread", "tomato", ...). */
	public static inline function ingredientNameById(id:String):String {
		return I18n.t("ingredients." + id.toLowerCase());
	}

	public static inline function ingredientState(state:IngredientState):String {
		return I18n.t("ingredients.state." + Std.string(state).toLowerCase());
	}

	public static function camelToSnake(s:String):String {
		var out = new StringBuf();
		for (i in 0...s.length) {
			var ch = s.charCodeAt(i);
			if (ch >= 65 && ch <= 90) {
				if (i > 0) out.add("_");
				out.addChar(ch + 32);
			} else {
				out.addChar(ch);
			}
		}
		return out.toString();
	}
}
