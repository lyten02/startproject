package game.recipes;

import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Ingredient.IngredientType;

/**
 * Pure in-memory registry of IngredientMeta keyed by IngredientType. Populated
 * by IngredientCatalog.parse(json) at startup. No Heaps deps → test-friendly.
 *
 * Access methods fall back to safe defaults if metadata for a type is missing,
 * so pre-load test code and offline enum use keep working.
 */
class IngredientCatalog {
	public static inline var DEFAULT_FRESHNESS:Float = 120;

	static var byType:Map<IngredientType, IngredientMeta> = new Map();
	static var byId:Map<String, IngredientType>           = new Map();

	public static function parse(json:String):Void {
		var raw:Dynamic = haxe.Json.parse(json);
		if (raw == null) throw "IngredientCatalog: empty JSON";
		if (raw.ingredients == null) throw 'IngredientCatalog: missing "ingredients" array';

		var nextByType:Map<IngredientType, IngredientMeta> = new Map();
		var nextById:Map<String, IngredientType>           = new Map();
		var list:Array<Dynamic> = raw.ingredients;

		for (i in 0...list.length) {
			var e = list[i];
			if (e.id == null)   throw 'IngredientCatalog: entry[$i] missing "id"';
			if (e.type == null) throw 'IngredientCatalog: entry[$i] ("${e.id}") missing "type"';
			var type:IngredientType = try Type.createEnum(IngredientType, e.type) catch (_:Dynamic)
				throw 'IngredientCatalog: entry[$i] unknown type "${e.type}"';
			if (nextByType.exists(type)) throw 'IngredientCatalog: duplicate type "${e.type}"';
			if (nextById.exists(e.id))   throw 'IngredientCatalog: duplicate id "${e.id}"';

			var states:Array<IngredientState> = [];
			if (e.allowed_states != null) {
				var arr:Array<String> = e.allowed_states;
				for (s in arr) states.push(parseState(s, e.id));
			}

			var byState = new Map<IngredientState, String>();
			if (e.icon_paths != null) {
				var raw:haxe.DynamicAccess<String> = e.icon_paths;
				for (k => v in raw) byState.set(parseState(k, e.id), v);
			}

			nextByType.set(type, {
				type: type,
				id: e.id,
				iconPath: e.icon_path != null ? e.icon_path : 'sprites/ingredients/${e.id}',
				iconPathByState: byState,
				i18nKey:  e.i18n_key  != null ? e.i18n_key  : 'ingredients.${e.id}',
				category: e.category  != null ? e.category  : "base",
				maxFreshness: e.default_freshness_seconds != null ? e.default_freshness_seconds : DEFAULT_FRESHNESS,
				allowedStates: states,
				premiumVariant: e.premium_variant,
			});
			nextById.set(e.id, type);
		}
		byType = nextByType;
		byId   = nextById;
	}

	public static function get(type:IngredientType):Null<IngredientMeta> {
		return byType.get(type);
	}

	public static function typeById(id:String):Null<IngredientType> {
		return byId.get(id);
	}

	public static inline function getMaxFreshness(type:IngredientType):Float {
		var m = byType.get(type);
		return m != null ? m.maxFreshness : DEFAULT_FRESHNESS;
	}

	/** Per-state sprite path, falling back to the base iconPath. */
	public static function iconPathFor(type:IngredientType, state:IngredientState):String {
		var m = byType.get(type);
		if (m == null) return "sprites/ingredients/unknown";
		var s = m.iconPathByState.get(state);
		return s != null ? s : m.iconPath;
	}

	public static function hasStateSprite(type:IngredientType, state:IngredientState):Bool {
		var m = byType.get(type);
		return m != null && m.iconPathByState.exists(state);
	}

	public static inline function isLoaded():Bool return byType.iterator().hasNext();

	public static function reset():Void {
		byType = new Map();
		byId   = new Map();
	}

	static function parseState(s:String, ownerId:String):IngredientState {
		return switch s.toLowerCase() {
			case "raw":     Raw;
			case "chopped": Chopped;
			case "cooked":  Cooked;
			case "boiled":  Boiled;
			case "burnt":   Burnt;
			case "spoiled": Spoiled;
			default: throw 'IngredientCatalog: "$ownerId" has unknown state "$s"';
		}
	}
}
