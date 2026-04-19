package game.ui.held;

import game.core.IngredientPalette;
import game.ecs.World;
import game.ecs.components.Dish;
import game.ecs.components.Hands;
import game.ecs.components.Ingredient;
import game.ecs.components.Plate;
import game.ecs.components.PlayerControlled;
import game.i18n.GameI18n;
import game.ui.mvp.IPresenter;
import loc.base.I18nContract.PlaceholderArgs;
import loc.text.I18n;

/**
 * Populates HeldItemModel from the player's currently-held entity.
 * Ingredient → type+state+freshness (coloured). Plate → "Plate" + count/max.
 * All user-facing strings are resolved via `I18n.t` / `GameI18n.*` so a
 * language change during play refreshes on the next tick.
 */
class HeldItemPresenter implements IPresenter {
	public var model(default, null):HeldItemModel;

	var view:HeldItemView;
	var world:World;

	public function new(view:HeldItemView, world:World) {
		this.view  = view;
		this.world = world;
		this.model = new HeldItemModel();
	}

	public function update(dt:Float):Void {
		var players = world.query(PlayerControlled);
		if (players.length == 0) { hide(); return; }
		var hands = players[0].get(Hands);
		if (hands == null || hands.held == null) { hide(); return; }

		var held = hands.held;
		var dish = held.get(Dish);
		if (dish != null) {
			model.visible   = true;
			model.title     = GameI18n.recipeName(dish.type);
			model.tint      = 0xFFFFFF;
			model.body      = I18n.t("ui.held.ready");
			model.bodyColor = 0x88FF88;
			view.render(model);
			return;
		}
		var ing = held.get(Ingredient);
		if (ing != null) {
			model.visible   = true;
			model.title     = GameI18n.ingredientName(ing.type);
			model.tint      = 0xFFFFFF;
			model.body      = '${I18n.t("ui.held.state_label")}: ${GameI18n.ingredientState(ing.state)}\n${I18n.t("ui.held.freshness_label")} ${Std.int(ing.freshness)}/${Std.int(ing.maxFreshness)}';
			model.bodyColor = IngredientPalette.freshnessColor(ing.freshness, ing.maxFreshness);
			view.render(model);
			return;
		}
		var plate = held.get(Plate);
		if (plate != null) {
			model.visible   = true;
			model.title     = plate.dirty ? I18n.t("ui.held.plate_dirty") : I18n.t("ui.held.plate");
			model.tint      = 0xFFFFFF;
			if (plate.dish != null) {
				var args:PlaceholderArgs = new haxe.DynamicAccess<String>();
				args.set("name", GameI18n.recipeName(plate.dish.type));
				model.body      = I18n.t("ui.held.dish_ready", args);
				model.bodyColor = 0x88FF88;
			} else {
				var summary = plateSummary(plate);
				model.body      = summary != "" ? '${plate.contents.length}/${Plate.MAX}\n$summary' : '${plate.contents.length}/${Plate.MAX}';
				model.bodyColor = 0xFFEFA3;
			}
			view.render(model);
			return;
		}
		model.visible   = true;
		model.title     = I18n.t("ui.held.item");
		model.tint      = 0xFFFFFF;
		model.body      = "";
		model.bodyColor = 0xFFFFFF;
		view.render(model);
	}

	public function dispose():Void {}

	static function plateSummary(p:Plate):String {
		if (p.contents.length == 0) return "";
		var max = p.contents.length < 3 ? p.contents.length : 3;
		var parts = [];
		for (i in 0...max) parts.push(GameI18n.ingredientName(p.contents[i].type));
		if (p.contents.length > 3) parts.push("...");
		return parts.join(", ");
	}

	inline function hide():Void {
		model.visible = false;
		view.render(model);
	}
}
