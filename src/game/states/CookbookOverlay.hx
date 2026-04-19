package game.states;

import game.i18n.GameI18n;
import game.recipes.Recipe;
import game.recipes.RecipeBook;
import game.render.SceneScaler;
import h2d.Bitmap;
import h2d.Object;
import h2d.Text;
import h2d.Tile;
import loc.base.LocEvent;
import loc.text.I18n;
import loc.text.reactive.ReactiveText;

/**
 * Full-screen overlay listing every recipe with its ingredients and ordering.
 * Read-only UI — content is built once in the constructor from RecipeBook.ALL.
 * Toggled via GameplayState on the Cookbook action.
 */
class CookbookOverlay {
	public var visible(get, set):Bool;

	static inline var PANEL_PAD:Float = 24;
	static inline var LINE_STEP:Float = 26;
	static inline var TITLE_OFFSET:Float = 40;

	var root:Object;
	var dim:Bitmap;
	var panel:Bitmap;
	var title:Text;
	var lines:Array<Text> = [];
	var panelW:Float = 0;
	var panelH:Float = 0;
	var unlisten:Void->Void;

	public function new(parent:Object, font:h2d.Font) {
		root = new Object(parent);
		dim  = new Bitmap(Tile.fromColor(0x000000, 1, 1, 0.55), root);
		panel = new Bitmap(Tile.fromColor(0x1A1A22, 1, 1, 0.92), root);

		title = new ReactiveText(font, "ui.cookbook_title", root);
		title.smooth = true;
		title.textColor = 0xFFD166;

		for (r in RecipeBook.ALL) {
			var t = new Text(font, root);
			t.smooth = true;
			t.textColor = 0xE8E8F2;
			t.text = formatRecipe(r);
			lines.push(t);
		}

		relayout();
		unlisten = I18n.signal.listen(onLocEvent);
		root.visible = false;
	}

	function onLocEvent(e:LocEvent):Void {
		switch e {
			case Change(_), Loaded(_):
				for (i in 0...lines.length) lines[i].text = formatRecipe(RecipeBook.ALL[i]);
				relayout();
			case MissingKey(_, _):
		}
	}

	function relayout():Void {
		var maxLineW:Float = title.textWidth;
		for (t in lines) if (t.textWidth > maxLineW) maxLineW = t.textWidth;
		panelW = maxLineW + PANEL_PAD * 2;
		panelH = TITLE_OFFSET + LINE_STEP * lines.length + PANEL_PAD;
	}

	public function position(scaler:SceneScaler):Void {
		dim.scaleX = scaler.vW;
		dim.scaleY = scaler.vH;

		var px = (scaler.vW - panelW) * 0.5;
		var py = (scaler.vH - panelH) * 0.5;
		panel.x = px;
		panel.y = py;
		panel.scaleX = panelW;
		panel.scaleY = panelH;

		title.x = px + PANEL_PAD;
		title.y = py + PANEL_PAD * 0.5;

		for (i in 0...lines.length) {
			lines[i].x = px + PANEL_PAD;
			lines[i].y = py + TITLE_OFFSET + i * LINE_STEP;
		}

		if (root.parent != null) root.parent.addChild(root); // keep on top
	}

	public function dispose():Void {
		if (unlisten != null) { unlisten(); unlisten = null; }
		if (root != null) root.remove();
	}

	static function formatRecipe(r:Recipe):String {
		var parts = [];
		for (it in r.items) {
			var typeLabel = GameI18n.ingredientName(it.type);
			parts.push(it.state != null ? '$typeLabel(${GameI18n.ingredientState(it.state)})' : typeLabel);
		}
		var order = r.ordered ? I18n.t("ui.recipe_ordered") : I18n.t("ui.recipe_any_order");
		return '${GameI18n.recipeName(r.id)} $order: ' + parts.join(", ");
	}

	inline function get_visible():Bool return root.visible;
	inline function set_visible(v:Bool):Bool return root.visible = v;
}
