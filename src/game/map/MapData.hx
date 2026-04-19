package game.map;

/** JSON map format. Coordinates are grid cells (Grid.CELL = 32 px). */
typedef MapEntity = {
	var type:String;     // "player" | "circle" | "triangle" | "diamond" | "hexagon" | "rect"
	var x:Int;           // grid col
	var y:Int;           // grid row
	@:optional var w:Int;
	@:optional var h:Int;
	@:optional var r:Int;
	@:optional var color:Int;    // 0xRRGGBB — overrides default tint
	@:optional var label:String; // free-form text rendered above entity
	@:optional var surface:Bool; // treat this entity as a placement Surface
	@:optional var stock:Int;    // Dispenser initial stock; presence also marks the entity as a Dispenser
	@:optional var trash:Bool;   // treat as garbage bin (destroys items on throw/interact)
	@:optional var ingredient:String; // for ingredient-dispenser: tomato/meat/bread/…
	@:optional var station:String;    // pan/pot/board/sink — attaches Station component + icon
	@:optional var stand:Bool;        // marks Surface as a clean-plates stand (auto-destination)
	@:optional var serve:Bool;        // marks Surface as an order serve-window (OrderDeliverySystem target)
}

typedef MapData = {
	var width:Int;               // grid cols (bounds)
	var height:Int;              // grid rows
	var entities:Array<MapEntity>;
}
