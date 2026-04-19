package game.ui.orders;

/** One ingredient icon shown on an order card. */
typedef OrderIngredientIcon = {
	iconPath:String, // resource path without extension, e.g. "sprites/ingredients/meat_cooked"
	tint:Int,        // RGB multiply (IngredientPalette.tintFor(state))
};

/** Snapshot of one active order, consumed by OrderCardView. */
typedef OrderCardEntry = {
	dishKey:String,                    // i18n key for the dish name
	patienceRatio:Float,               // [0..1] — 1 = just spawned, 0 = expired
	barColor:Int,                      // ARGB for the patience bar fill
	ingredients:Array<OrderIngredientIcon>, // rendered below the title
};
