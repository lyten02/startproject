package game.map;

import game.map.MapData.MapEntity;

/**
 * Pure JSON → MapData parser. Throws on malformed input.
 * No engine deps → unit-testable.
 */
class MapLoader {
	public static function parse(json:String):MapData {
		var raw:Dynamic = haxe.Json.parse(json);
		if (raw == null) throw "MapLoader: empty JSON";
		if (raw.width == null || raw.height == null) throw "MapLoader: missing width/height";
		if (raw.entities == null) throw "MapLoader: missing entities array";

		var entities:Array<MapEntity> = [];
		var rawEntities:Array<Dynamic> = raw.entities;
		for (i in 0...rawEntities.length) {
			var e = rawEntities[i];
			if (e.type == null) throw 'MapLoader: entity[$i] missing "type"';
			if (e.x == null || e.y == null) throw 'MapLoader: entity[$i] missing x/y';
			entities.push({
				type:    e.type,
				x:       e.x,
				y:       e.y,
				w:       e.w,
				h:       e.h,
				r:       e.r,
				color:   e.color,
				label:   e.label,
				surface: e.surface,
				stock:   e.stock,
				trash:      e.trash,
				ingredient: e.ingredient,
				station:    e.station,
				stand:      e.stand,
				serve:      e.serve,
			});
		}

		return { width: raw.width, height: raw.height, entities: entities };
	}
}
