package game.ui.orders;

import game.core.IngredientPalette;
import game.ecs.World;
import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Order;
import game.ecs.components.OrderQueue;
import game.recipes.IngredientCatalog;
import game.recipes.RecipeBook;
import game.ui.mvp.IPresenter;
import game.ui.orders.OrderCardEntry.OrderIngredientIcon;

/**
 * Reads the singleton OrderQueue + each active Order entity, maps them to
 * OrderCardEntry (dish i18n key, patience ratio + colour, recipe icons) and
 * pushes the model to the view. No game-state mutation.
 */
class OrderQueuePresenter implements IPresenter {
	public var model(default, null):OrderQueueModel;

	var view:OrderQueueView;
	var world:World;

	public function new(view:OrderQueueView, world:World) {
		this.view  = view;
		this.world = world;
		this.model = new OrderQueueModel();
	}

	public function update(_:Float):Void {
		var qs = world.query(OrderQueue);
		if (qs.length == 0 || qs[0].get(OrderQueue).orders.length == 0) {
			model.visible = false;
			model.entries = [];
			view.render(model);
			return;
		}
		var q = qs[0].get(OrderQueue);
		var out:Array<OrderCardEntry> = [];
		for (oEnt in q.orders) {
			var o = oEnt.get(Order);
			if (o == null) continue;
			var ratio = o.patienceRatio();
			out.push({
				dishKey:       dishI18nKey(o.dishType),
				patienceRatio: ratio,
				barColor:      patienceColor(ratio),
				ingredients:   recipeIcons(o.dishType),
			});
		}
		model.visible = out.length > 0;
		model.entries = out;
		view.render(model);
	}

	public function dispose():Void {}

	static inline function dishI18nKey(id:game.ecs.components.Dish.DishType):String {
		var meta = RecipeBook.findMeta(id);
		return meta != null ? meta.i18nKey : "recipes." + game.i18n.GameI18n.camelToSnake(Std.string(id));
	}

	static function recipeIcons(id:game.ecs.components.Dish.DishType):Array<OrderIngredientIcon> {
		var r = RecipeBook.findById(id);
		if (r == null) return [];
		var out:Array<OrderIngredientIcon> = [];
		for (it in r.items) {
			var state:IngredientState = it.state != null ? it.state : Raw;
			out.push({
				iconPath: IngredientCatalog.iconPathFor(it.type, state),
				tint:     IngredientPalette.tintFor(state),
			});
		}
		return out;
	}

	/** Green → yellow → red as patience drains. */
	static function patienceColor(ratio:Float):Int {
		if (ratio > 0.5) return 0x7CFC8A;
		if (ratio > 0.2) return 0xFFD070;
		return 0xFF6060;
	}
}
