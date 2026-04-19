package game.systems;

import game.core.Grid;
import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.Collider;
import game.ecs.components.Ingredient;
import game.ecs.components.Ingredient.IngredientState;
import game.ecs.components.Plate;
import game.ecs.components.SinkQueue;
import game.ecs.components.PlayerControlled;
import game.ecs.components.Station;
import game.ecs.components.Station.StationKind;
import game.ecs.components.Surface;
import game.ecs.components.Transform;
import game.input.GameAction;
import game.input.InputBindings;
import h2d.Graphics;

/**
 * Passive processing for every Station kind:
 *   - Pan/Pot: Ingredient Raw → successState → Burnt.
 *   - Board:   Ingredient Raw → Chopped (no burn, burnSec = 999).
 *   - Sink:    dirty Plate → clean after `cookSec` seconds, `washTime` reset
 *              when plate leaves the cell or becomes dirty again.
 * A thin progress bar is drawn above whatever sits on the station.
 */
class CookingSystem implements ISystem {
	static inline var BAR_W:Float = 28;
	static inline var BAR_H:Float = 4;
	static inline var BAR_GAP:Float = 8;

	var root:h2d.Object;
	var g:Graphics;
	var input:InputBindings;

	public function new(root:h2d.Object, input:InputBindings) {
		this.root  = root;
		this.input = input;
		this.g     = new Graphics(root);
	}

	public function update(world:World, dt:Float):Void {
		g.clear();
		if (g.parent != null) g.parent.addChild(g); // stay above late-added layers
		// Reset wash timers on plates not sitting on any sink this frame.
		for (pe in world.query(Plate)) {
			var p = pe.get(Plate);
			if (!p.dirty || p.washTime == 0) p.washTime = 0;
		}

		var player = firstPlayer(world);

		for (station in world.query(Station)) {
			var st   = station.get(Station);
			var surf = station.get(Surface);
			if (surf == null) continue;

			// Interactive stations (Board/Sink) only advance while the player is
			// facing this station AND holding E. Pan/Pot run on their own.
			if (st.requiresHold()) {
				if (player == null) continue;
				if (!input.isDown(GameAction.Interact)) continue;
				if (!playerFacing(player, station)) continue;
			}

			if (st.kind == Sink) tickSink(world, station, st, surf, dt);
			else                 tickCook(world, station, st, surf, dt);
		}
	}

	static function firstPlayer(world:World):Entity {
		var ps = world.query(PlayerControlled);
		return ps.length > 0 ? ps[0] : null;
	}

	static function playerFacing(player:Entity, station:Entity):Bool {
		var cell = InteractQueries.facingCell(player);
		var tr = station.get(Transform);
		var co = station.get(Collider);
		if (tr == null || co == null) return false;
		var x0 = Std.int(tr.pos.x / Grid.CELL);
		var y0 = Std.int(tr.pos.y / Grid.CELL);
		var x1 = Std.int((tr.pos.x + co.w - 1) / Grid.CELL);
		var y1 = Std.int((tr.pos.y + co.h - 1) / Grid.CELL);
		return cell.x >= x0 && cell.x <= x1 && cell.y >= y0 && cell.y <= y1;
	}

	function tickCook(world:World, station:Entity, st:Station, surf:Surface, dt:Float):Void {
		var item = findOnStation(station, surf, true);
		if (item == null) return;
		var ing = item.get(Ingredient);
		if (ing.state == Burnt || ing.state == Spoiled) return;

		ing.processedTime += dt;
		var cook = st.cookSec();
		var burn = cook + st.burnSec();
		if (ing.state == Raw && ing.processedTime >= cook) ing.state = st.successState();
		if (ing.processedTime >= burn) ing.state = Burnt;

		drawBar(item, ing.processedTime, cook, burn, ing.state == Raw);
	}

	function tickSink(world:World, station:Entity, st:Station, surf:Surface, dt:Float):Void {
		var q = station.get(SinkQueue);
		// Priority 1: wash the first dirty plate in queue.
		var dirtyItem:Entity = null;
		if (q != null) {
			for (p in q.plates) if (p.get(Plate) != null && p.get(Plate).dirty) { dirtyItem = p; break; }
		}
		if (dirtyItem != null) {
			var p = dirtyItem.get(Plate);
			p.washTime += dt;
			var wash = st.cookSec();
			if (p.washTime >= wash) {
				p.dirty = false;
				p.washTime = 0;
				if (q != null) SinkQueueSystem.transferToStand(world, q, dirtyItem);
				return;
			}
			drawBar(dirtyItem, p.washTime, wash, wash, true);
			return;
		}
		// Priority 2: no dirty plates — hold-E on clean plates sends them to stand one by one.
		if (q != null && q.plates.length > 0) {
			var clean = q.plates[0];
			SinkQueueSystem.transferToStand(world, q, clean);
		}
	}

	static function findOnStation(station:Entity, surf:Surface, wantIngredient:Bool):Entity {
		var tr = station.get(Transform);
		var co = station.get(Collider);
		if (tr == null || co == null) return null;
		var x0 = Std.int(tr.pos.x / Grid.CELL);
		var y0 = Std.int(tr.pos.y / Grid.CELL);
		var x1 = Std.int((tr.pos.x + co.w - 1) / Grid.CELL);
		var y1 = Std.int((tr.pos.y + co.h - 1) / Grid.CELL);
		for (cx in x0...x1 + 1) for (cy in y0...y1 + 1) {
			var occ = surf.occupantAt(cx, cy);
			if (occ == null) continue;
			if (wantIngredient) {
				if (occ.get(Ingredient) != null && occ.get(Plate) == null) return occ;
			} else {
				if (occ.get(Plate) != null) return occ;
			}
		}
		return null;
	}

	function drawBar(item:Entity, progress:Float, doneAt:Float, burnAt:Float, active:Bool):Void {
		var tr = item.get(Transform);
		var co = item.get(Collider);
		if (tr == null || co == null) return;

		var ratio:Float;
		var color:Int;
		if (active) {
			ratio = progress / doneAt;
			color = 0x7CFC8A;
		} else {
			ratio = (progress - doneAt) / (burnAt - doneAt);
			color = ratio > 0.66 ? 0xFF6060 : 0xFFD166;
		}
		if (ratio < 0) ratio = 0;
		if (ratio > 1) ratio = 1;

		var x = tr.pos.x + (co.w - BAR_W) * 0.5;
		var y = tr.pos.y - BAR_H - BAR_GAP;
		g.beginFill(0x000000, 0.55);
		g.drawRect(x, y, BAR_W, BAR_H);
		g.endFill();
		g.beginFill(color, 1);
		g.drawRect(x, y, BAR_W * ratio, BAR_H);
		g.endFill();
		g.lineStyle(1, 0xFFFFFF, 0.7);
		g.drawRect(x, y, BAR_W, BAR_H);
	}
}
