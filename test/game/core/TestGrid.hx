package game.core;

import utest.Assert;
import utest.Test;

class TestGrid extends Test {
	function testCellSizeIs32() {
		Assert.equals(32, Grid.CELL);
	}

	function testCellToPx() {
		Assert.equals(0.0,   Grid.cellToPx(0));
		Assert.equals(32.0,  Grid.cellToPx(1));
		Assert.equals(160.0, Grid.cellToPx(5));
	}

	function testPxToCell() {
		Assert.equals(0, Grid.pxToCell(0));
		Assert.equals(1, Grid.pxToCell(32));
		Assert.equals(1, Grid.pxToCell(45));  // rounds toward zero
		Assert.equals(5, Grid.pxToCell(160));
	}
}
