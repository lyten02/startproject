package game.ui.orders;

import game.ui.orders.OrderCardEntry.OrderIngredientIcon;
import h2d.Bitmap;
import h2d.Flow;
import h2d.Graphics;

/**
 * One order card: localized dish name → patience bar → row of recipe icons.
 * Render-only; parent OrderQueueView hands it an OrderCardEntry each frame
 * via `apply()`. Layout stays narrow: title is downscaled, icons wrap at
 * BAR_W so many-ingredient dishes span two rows instead of stretching wide.
 */
@:uiComp("order-card")
class OrderCardView extends h2d.Flow implements h2d.domkit.Object {
	public static inline var BAR_W:Float = 100;
	public static inline var BAR_H:Float = 10;
	public static inline var ICON:Float  = 18;

	static var SRC = <order-card>
		<text public id="titleText" class="title" text={""}/>
		<flow public id="barHolder" class="bar-holder"/>
		<flow public id="iconRow" layout="horizontal"/>
	</order-card>;

	var bar:Graphics;
	var iconSlots:Array<Bitmap> = [];

	public function new(font:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		titleText.font   = font;
		titleText.smooth = true;
		titleText.scaleX = 0.75;
		titleText.scaleY = 0.75;
		titleText.maxWidth = BAR_W / 0.75;

		barHolder.minWidth  = Std.int(BAR_W);
		barHolder.minHeight = Std.int(BAR_H);
		bar = new Graphics(barHolder);

		iconRow.layout = Horizontal;
		iconRow.multiline = true;
		iconRow.maxWidth = Std.int(BAR_W);
		iconRow.horizontalSpacing = 4;
		iconRow.verticalSpacing = 2;
	}

	public function apply(label:String, ratio:Float, color:Int, icons:Array<OrderIngredientIcon>):Void {
		titleText.text = label;
		applyIcons(icons);
		drawBar(ratio, color);
	}

	function applyIcons(icons:Array<OrderIngredientIcon>):Void {
		while (iconSlots.length < icons.length) iconSlots.push(new Bitmap(null, iconRow));
		for (i in 0...iconSlots.length) {
			var slot = iconSlots[i];
			if (i >= icons.length) { slot.visible = false; continue; }
			var ic = icons[i];
			var tile = tileFor(ic.iconPath);
			slot.tile = tile;
			slot.color.setColor(0xFF000000 | ic.tint);
			slot.smooth = true;
			slot.visible = tile != null;
			if (tile != null) {
				slot.scaleX = ICON / tile.width;
				slot.scaleY = ICON / tile.height;
			}
		}
	}

	function drawBar(ratio:Float, fill:Int):Void {
		if (ratio < 0) ratio = 0;
		if (ratio > 1) ratio = 1;
		bar.clear();
		bar.beginFill(0x000000, 0.6);
		bar.drawRect(0, 0, BAR_W, BAR_H);
		bar.endFill();
		if (ratio > 0) {
			bar.beginFill(fill, 1);
			bar.drawRect(0, 0, BAR_W * ratio, BAR_H);
			bar.endFill();
		}
		bar.lineStyle(1, 0xFFFFFF, 0.8);
		bar.drawRect(0, 0, BAR_W, BAR_H);
	}

	static function tileFor(path:String):h2d.Tile {
		return try hxd.Res.load(path + ".png").toTile() catch (_:Dynamic) null;
	}
}
