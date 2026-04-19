package game.ecs.components;

import game.ecs.components.Dish.DishType;
import utest.Assert;
import utest.Test;

class TestOrder extends Test {
	function testInitialPatienceMatchesMax() {
		var o = new Order(Sandwich, 30, 10);
		Assert.equals(Sandwich, o.dishType);
		Assert.equals(30.0, o.patienceSec);
		Assert.equals(30.0, o.maxPatienceSec);
		Assert.equals(10, o.reward);
		Assert.equals(0.0, o.ageSec);
	}

	function testPatienceRatioStartsAtOne() {
		var o = new Order(Bruschetta, 60, 0);
		Assert.equals(1.0, o.patienceRatio());
	}

	function testPatienceRatioHalfway() {
		var o = new Order(ClassicBurger, 40, 0);
		o.patienceSec = 20;
		Assert.equals(0.5, o.patienceRatio());
	}

	function testPatienceRatioZeroWhenDrained() {
		var o = new Order(CheeseBurger, 10, 0);
		o.patienceSec = 0;
		Assert.equals(0.0, o.patienceRatio());
	}

	function testZeroMaxPatienceReturnsZeroRatio() {
		var o = new Order(RoyalBurger, 0.0001, 0);
		o.maxPatienceSec = 0;
		Assert.equals(0.0, o.patienceRatio());
	}
}
