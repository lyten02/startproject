package game.ui.held;

/** Data for HeldItemView — compact status of the entity currently in Hands. */
class HeldItemModel {
	public var visible:Bool = false;
	public var title:String = "";       // "Tomato", "Plate"
	public var body:String = "";         // "state: Raw\nfresh 20/120", "3/10"
	public var bodyColor:Int = 0xFFFFFF; // freshness-driven colour for body line
	public var tint:Int = 0xFFFFFF;      // future hook for coloured title

	public function new() {}
}
