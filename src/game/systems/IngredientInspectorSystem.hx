package game.systems;

import game.core.IngredientPalette;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Carryable;
import game.ecs.components.Collider;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Transform;
import game.i18n.GameI18n;
import h2d.Font;
import h2d.Text;
import loc.text.I18n;

/**
 * Debug tooltip over the entity in the player's facing cell.
 * Handles both Ingredient (type/state/freshness) and Plate (count + first 4
 * item types). Single Text node reused each frame.
 */
class IngredientInspectorSystem implements ISystem {
	var root:h2d.Object;
	var label:Text;

	public function new(root:h2d.Object, font:Font) {
		this.root  = root;
		this.label = new Text(font, root);
		this.label.textAlign = Center;
		this.label.textColor = 0xFFEFA3;
		this.label.visible   = false;
		this.label.smooth    = true;
	}

	public function update(world:World, dt:Float):Void {
		var players = world.query(PlayerControlled);
		if (players.length == 0) { label.visible = false; return; }
		var cell = InteractQueries.facingCell(players[0]);

		var ingTarget = findIngredientAtCell(world, cell.x, cell.y);
		if (ingTarget != null) { renderIngredient(ingTarget); return; }

		var plateTarget = findPlateAtCell(world, cell.x, cell.y);
		if (plateTarget != null) { renderPlate(plateTarget); return; }

		label.visible = false;
	}

	function renderIngredient(e:Entity):Void {
		var ing = e.get(Ingredient);
		var tr  = e.get(Transform);
		var co  = e.get(Collider);
		var typeLabel  = GameI18n.ingredientName(ing.type);
		var stateLabel = GameI18n.ingredientState(ing.state);
		label.text = '$typeLabel  |  $stateLabel\n${I18n.t("ui.held.freshness_label")} ${Std.int(ing.freshness)}/${Std.int(ing.maxFreshness)}';
		label.textColor = IngredientPalette.freshnessColor(ing.freshness, ing.maxFreshness);
		label.visible = true;
		label.x = tr.pos.x + (co != null ? co.w * 0.5 : 0);
		label.y = tr.pos.y - label.textHeight - 8;
		bringToFront();
	}

	function renderPlate(e:Entity):Void {
		var p  = e.get(Plate);
		var tr = e.get(Transform);
		var co = e.get(Collider);
		var args:loc.base.I18nContract.PlaceholderArgs = new haxe.DynamicAccess<String>();
		var header:String;
		if (p.dish != null) {
			args.set("name", GameI18n.recipeName(p.dish.type));
			header = I18n.t("ui.inspector.plate_ready", args);
		} else {
			var dirty = p.dirty ? " " + I18n.t("ui.inspector.dirty_suffix") : "";
			header = 'Plate ${p.contents.length}/${Plate.MAX}$dirty';
		}
		label.text = p.dish != null ? header : '$header\n${summary(p)}';
		label.textColor = 0xFFEFA3;
		label.visible = true;
		label.x = tr.pos.x + (co != null ? co.w * 0.5 : 0);
		label.y = tr.pos.y - label.textHeight - 16;
		bringToFront();
	}

	inline function bringToFront():Void {
		if (label.parent != null) label.parent.addChild(label);
	}

	static function summary(p:Plate):String {
		if (p.contents.length == 0) return I18n.t("ui.inspector.empty");
		var max = p.contents.length < 4 ? p.contents.length : 4;
		var parts = [];
		for (i in 0...max) parts.push(GameI18n.ingredientName(p.contents[i].type));
		if (p.contents.length > 4) parts.push("...");
		return parts.join(", ");
	}

	static function findIngredientAtCell(world:World, cx:Int, cy:Int):Entity {
		for (e in world.query(Ingredient)) if (matchesCell(e, cx, cy)) return e;
		return null;
	}

	static function findPlateAtCell(world:World, cx:Int, cy:Int):Entity {
		for (e in world.query(Plate)) if (matchesCell(e, cx, cy)) return e;
		return null;
	}

	static function matchesCell(e:Entity, cx:Int, cy:Int):Bool {
		var car = e.get(Carryable);
		if (car != null && car.heldBy != null) return false;
		var tr = e.get(Transform);
		var co = e.get(Collider);
		if (tr == null || co == null) return false;
		var ecx = Std.int((tr.pos.x + co.w * 0.5) / game.core.Grid.CELL);
		var ecy = Std.int((tr.pos.y + co.h * 0.5) / game.core.Grid.CELL);
		return ecx == cx && ecy == cy;
	}
}
