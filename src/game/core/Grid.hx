package game.core;

/** Grid ↔ pixel conversion. Maps are defined in grid cells (32×32 px each). */
class Grid {
	public static inline var CELL:Int = 32;

	public static inline function cellToPx(cell:Int):Float return cell * CELL;
	public static inline function pxToCell(px:Float):Int return Std.int(px / CELL);
}
