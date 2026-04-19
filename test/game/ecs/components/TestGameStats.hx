package game.ecs.components;

import utest.Assert;
import utest.Test;

class TestGameStats extends Test {
	function testDefaultsAreZero() {
		var s = new GameStats();
		Assert.equals(0, s.served);
		Assert.equals(0, s.failed);
		Assert.equals(0, s.money);
	}

	function testRecordServedIncrementsCountAndMoney() {
		var s = new GameStats();
		s.recordServed(20);
		s.recordServed(15);
		Assert.equals(2,  s.served);
		Assert.equals(35, s.money);
		Assert.equals(0,  s.failed);
	}

	function testRecordFailedOnlyBumpsFailed() {
		var s = new GameStats();
		s.recordFailed();
		s.recordFailed();
		Assert.equals(2, s.failed);
		Assert.equals(0, s.served);
		Assert.equals(0, s.money);
	}

	function testNegativeOrZeroRewardAllowed() {
		var s = new GameStats();
		s.recordServed(0);
		Assert.equals(1, s.served);
		Assert.equals(0, s.money);
	}
}
