package game.map;

import utest.Assert;
import utest.Test;

class TestMapLoader extends Test {
	function testParsesWidthHeight() {
		var json = '{ "width": 60, "height": 34, "entities": [] }';
		var m = MapLoader.parse(json);
		Assert.equals(60, m.width);
		Assert.equals(34, m.height);
		Assert.equals(0, m.entities.length);
	}

	function testParsesEntities() {
		var json = '{ "width": 10, "height": 10, "entities": ['
			+ '{ "type": "player",   "x": 1, "y": 2 },'
			+ '{ "type": "circle",   "x": 3, "y": 4, "r": 2 }'
			+ ']}';
		var m = MapLoader.parse(json);
		Assert.equals(2, m.entities.length);
		Assert.equals("player", m.entities[0].type);
		Assert.equals(1, m.entities[0].x);
		Assert.equals("circle", m.entities[1].type);
		Assert.equals(2, m.entities[1].r);
	}

	function testThrowsOnMissingEntities() {
		Assert.raises(() -> MapLoader.parse('{ "width": 1, "height": 1 }'));
	}

	function testThrowsOnEntityWithoutType() {
		Assert.raises(() -> MapLoader.parse('{ "width": 1, "height": 1, "entities": [{"x":0,"y":0}] }'));
	}

	function testThrowsOnEmptyInput() {
		Assert.raises(() -> MapLoader.parse('null'));
	}
}
