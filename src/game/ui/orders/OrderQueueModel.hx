package game.ui.orders;

/** Data for OrderQueueView — the set of active order cards to render. */
class OrderQueueModel {
	public var visible:Bool = false;
	public var entries:Array<OrderCardEntry> = [];

	public function new() {}
}
