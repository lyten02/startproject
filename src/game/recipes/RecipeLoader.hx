package game.recipes;

import game.ecs.components.Dish.DishType;
import game.ecs.components.Ingredient.IngredientState;
import game.recipes.Recipe;

typedef LoadedRecipes = {
	var recipes:Array<Recipe>;
	var meta:Map<DishType, RecipeMeta>;
};

/**
 * Pure JSON → Recipe array + RecipeMeta map. No Heaps/ECS deps.
 * Validates ingredient_id refs against IngredientCatalog.typeById; unknown
 * ids, states, or recipe ids raise a descriptive `String` exception.
 *
 * `count` is expanded into consecutive single-count entries so the matcher
 * stays multiset-simple. `position_index` is collected into parallel array
 * RecipeMeta.positions (not in the hot-path typedef).
 */
class RecipeLoader {
	public static function parse(json:String):LoadedRecipes {
		var raw:Dynamic = haxe.Json.parse(json);
		if (raw == null) throw "RecipeLoader: empty JSON";
		if (raw.recipes == null) throw 'RecipeLoader: missing "recipes" array';

		var recipes:Array<Recipe> = [];
		var meta:Map<DishType, RecipeMeta> = new Map();
		var list:Array<Dynamic> = raw.recipes;

		for (i in 0...list.length) {
			var e = list[i];
			if (e.id == null) throw 'RecipeLoader: entry[$i] missing "id"';
			var id:DishType = try Type.createEnum(DishType, e.id) catch (_:Dynamic)
				throw 'RecipeLoader: entry[$i] unknown recipe id "${e.id}"';
			if (meta.exists(id)) throw 'RecipeLoader: duplicate recipe id "${e.id}"';
			if (e.ingredients == null) throw 'RecipeLoader: "${e.id}" missing ingredients array';

			var items:Array<RecipeIngredient> = [];
			var positions:Array<Int> = [];
			var rawItems:Array<Dynamic> = e.ingredients;
			for (j in 0...rawItems.length) {
				var it = rawItems[j];
				if (it.ingredient_id == null) throw 'RecipeLoader: "${e.id}".items[$j] missing ingredient_id';
				var type = IngredientCatalog.typeById(it.ingredient_id);
				if (type == null) throw 'RecipeLoader: "${e.id}".items[$j] unknown ingredient "${it.ingredient_id}"';
				var state:Null<IngredientState> = it.required_state != null ? parseState(it.required_state, e.id) : null;
				var count:Int = it.count != null ? it.count : 1;
				var pos:Int = it.position_index != null ? it.position_index : items.length;
				for (_ in 0...count) {
					items.push({ type: type, state: state });
					positions.push(pos);
				}
			}

			var containers:Array<String> = e.allowed_containers != null ? e.allowed_containers : ["plate"];
			var maxTotal:Int = e.max_ingredients_total != null ? e.max_ingredients_total : -1;
			var fallback:String = e.fallback_behavior != null ? e.fallback_behavior : "block";
			var i18nKey:String = e.i18n_key != null ? e.i18n_key : 'recipes.${defaultI18nKey(e.id)}';

			recipes.push({
				id: id,
				ordered: e.strict_order == true,
				items: items,
			});
			meta.set(id, {
				id: id,
				i18nKey: i18nKey,
				resultIconPath: e.result_icon_path,
				allowedContainers: containers,
				maxIngredientsTotal: maxTotal,
				fallbackBehavior: fallback,
				positions: positions,
			});
		}
		return { recipes: recipes, meta: meta };
	}

	static function parseState(s:String, ownerId:String):IngredientState {
		return switch s.toLowerCase() {
			case "raw":     Raw;
			case "chopped": Chopped;
			case "cooked":  Cooked;
			case "boiled":  Boiled;
			case "burnt":   Burnt;
			case "spoiled": Spoiled;
			default: throw 'RecipeLoader: "$ownerId" has unknown required_state "$s"';
		}
	}

	static function defaultI18nKey(pascal:String):String {
		var out = new StringBuf();
		for (i in 0...pascal.length) {
			var c = pascal.charCodeAt(i);
			if (c >= 65 && c <= 90) {
				if (i > 0) out.add("_");
				out.addChar(c + 32);
			} else {
				out.addChar(c);
			}
		}
		return out.toString();
	}
}
