package game.ui.debug;

/** Plain data rendered by DebugView. Populated each frame by DebugPresenter. */
class DebugModel {
	public var fps:Int         = 0;
	public var frameMs:Float   = 0;
	public var playerPx:String = "-";
	public var playerCell:String = "-";
	public var entities:Int    = 0;
	public var heapMB:String   = "n/a";
	public var cpuPct:Int      = 0;
	public var drawCalls:Int   = 0;
	public var triangles:Int   = 0;
	public var startupMs:Int   = 0;
	public var uptimeSec:Int   = 0;
	public var speed:String    = "1.0x";
	public var zoom:String     = "1.0x";

	public function new() {}
}
