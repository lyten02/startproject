package game.systems;

import game.core.IngredientPalette;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Plate;
import game.ecs.components.Transform;
import game.map.DishFactory;
import game.recipes.IngredientCatalog;
import game.recipes.RecipeBook;
import h2d.Bitmap;
import h2d.Object;
import h2d.Tile;

/**
 * Draws each Plate's contents in two passes:
 *  - `onPlate`: a centred pile of icons (last N), stacked vertically with a
 *    small y-offset per slot — newest on top — overlapping the plate sprite.
 *  - `summary`: a small row of up to 4 icons above the plate for a quick
 *    at-a-glance read.
 *
 * Rebuilds children only when the plate's content signature changes;
 * repositions containers each frame (cheap).
 */
class PlateStackRenderSystem implements ISystem {
	static inline var MAX_ICONS:Int    = 4;
	static inline var ICON_SIZE:Float  = 10;
	static inline var SPACING:Float    = 2;
	static inline var OFFSET_Y:Float   = 4;

	static inline var PILE_ICON:Float  = 14;   // slightly smaller than plate AABB (20)
	static inline var PILE_STEP:Float  = 3;    // vertical stagger between layers
	static inline var PILE_MAX:Int     = 5;    // number of layers to render

	static var tileCache:Map<String, Tile> = new Map();

	var root:Object;
	var stacks:Map<Int, StackGroup> = new Map();
	var signatures:Map<Int, String> = new Map();

	public function new(root:Object) {
		this.root = root;
	}

	public function update(world:World, dt:Float):Void {
		var alive = new Map<Int, Bool>();

		for (e in world.query(Plate)) {
			alive.set(e.id, true);
			var p  = e.get(Plate);
			var tr = e.get(Transform);
			var co = e.get(Collider);
			if (tr == null || co == null) continue;

			var group = stacks.get(e.id);
			if (group == null) {
				group = { onPlate: new Object(root), summary: new Object(root) };
				stacks.set(e.id, group);
			}

			var sig = signature(p);
			if (signatures.get(e.id) != sig) {
				rebuildOnPlate(group.onPlate, p);
				rebuildSummary(group.summary, p);
				signatures.set(e.id, sig);
			}

			// On-plate pile: centred on plate AABB, slightly lifted by PILE_STEP.
			group.onPlate.x = tr.pos.x + co.w * 0.5;
			group.onPlate.y = tr.pos.y + co.h * 0.5;

			// Summary row above the plate.
			var count = p.contents.length < MAX_ICONS ? p.contents.length : MAX_ICONS;
			var rowW  = count * ICON_SIZE + (count > 0 ? (count - 1) * SPACING : 0);
			group.summary.x = tr.pos.x + (co.w - rowW) * 0.5;
			group.summary.y = tr.pos.y - ICON_SIZE - OFFSET_Y;
		}

		for (id in stacks.keys()) {
			if (!alive.exists(id)) {
				var g = stacks.get(id);
				g.onPlate.remove();
				g.summary.remove();
				stacks.remove(id);
				signatures.remove(id);
			}
		}
	}

	static function signature(p:Plate):String {
		if (p.dish != null) return "dish:" + p.dish.type;
		// Include both summary-range (first N) and pile-range (last M).
		var s = Std.string(p.contents.length);
		var summaryN = p.contents.length < MAX_ICONS ? p.contents.length : MAX_ICONS;
		for (i in 0...summaryN) s += '|${p.contents[i].type}:${p.contents[i].state}';
		var pileStart = p.contents.length - PILE_MAX;
		if (pileStart < 0) pileStart = 0;
		for (i in pileStart...p.contents.length) s += '>${p.contents[i].type}:${p.contents[i].state}';
		return s;
	}

	static function rebuildSummary(stack:Object, p:Plate):Void {
		while (stack.numChildren > 0) stack.getChildAt(0).remove();
		if (p.dish != null) return; // dish rendered on-plate only
		var n = p.contents.length < MAX_ICONS ? p.contents.length : MAX_ICONS;
		for (i in 0...n) {
			var bm = makeIcon(stack, p.contents[i], ICON_SIZE);
			bm.x = i * (ICON_SIZE + SPACING);
		}
	}

	static function rebuildOnPlate(stack:Object, p:Plate):Void {
		while (stack.numChildren > 0) stack.getChildAt(0).remove();
		if (p.dish != null) {
			var size = PILE_ICON + 4;
			var meta = RecipeBook.findMeta(p.dish.type);
			var path = meta != null && meta.resultIconPath != null ? meta.resultIconPath : "sprites/dishes/" + DishFactory.dishAsset(p.dish.type);
			var tile = tileCache.get(path);
			if (tile == null) { tile = hxd.Res.load(path + ".png").toImage().toTile(); tileCache.set(path, tile); }
			var bm = new Bitmap(tile, stack);
			var tw = tile.width > 0 ? tile.width : size;
			bm.setScale(size / tw);
			bm.x = -size * 0.5;
			bm.y = -size * 0.5 - PILE_STEP;
			return;
		}
		var len = p.contents.length;
		if (len == 0) return;
		var start = len - PILE_MAX;
		if (start < 0) start = 0;
		var layers = len - start;
		// Draw oldest-first so the newest ends up on top of the render stack.
		for (i in 0...layers) {
			var slot = p.contents[start + i];
			var bm = makeIcon(stack, slot, PILE_ICON);
			bm.x = -PILE_ICON * 0.5;
			bm.y = -PILE_ICON * 0.5 - i * PILE_STEP;
		}
	}

	static function makeIcon(parent:Object, slot:game.ecs.components.Plate.PlateSlot, size:Float):Bitmap {
		var path = IngredientCatalog.iconPathFor(slot.type, slot.state) + ".png";
		var tile = tileCache.get(path);
		if (tile == null) { tile = hxd.Res.load(path).toImage().toTile(); tileCache.set(path, tile); }

		var bm = new Bitmap(tile, parent);
		var tw = tile.width > 0 ? tile.width : size;
		bm.setScale(size / tw);

		if (!IngredientCatalog.hasStateSprite(slot.type, slot.state)) {
			var tint = IngredientPalette.tintFor(slot.state);
			var r = ((tint >> 16) & 0xFF) / 255;
			var g = ((tint >> 8)  & 0xFF) / 255;
			var b = ( tint        & 0xFF) / 255;
			bm.color.set(r, g, b, 1);
		}
		return bm;
	}
}

typedef StackGroup = { onPlate:Object, summary:Object };
