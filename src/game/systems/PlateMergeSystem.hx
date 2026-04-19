package game.systems;

import game.ecs.Entity;
import game.ecs.World;
import game.ecs.components.ActionFeedback;
import game.ecs.components.Dish;
import game.ecs.components.Plate;
import game.i18n.GameI18n;
import game.recipes.RecipeMatcher;

/**
 * Stateless merge orchestration. Called by PlateActions after every
 * successful ingredient placement onto a plate. If plate.contents match a
 * recipe, contents are snapshotted into plate.dish and cleared.
 *
 * The Plate entity itself persists (keeps wash cycle + Carryable). The dish
 * rides on the plate via plate.dish and is "popped" as a separate entity by
 * PlateActions.takeFromPlate when the player picks from the plate.
 *
 * player may be null (tests) — notifications are skipped in that case.
 */
class PlateMergeSystem {
	public static function tryMerge(world:World, plateEntity:Entity, player:Entity):Bool {
		var plate = plateEntity.get(Plate);
		if (plate == null) return false;
		if (plate.dish != null) return false; // already merged; idempotent
		if (plate.hasStack()) return false;   // don't merge while stacked

		var recipe = RecipeMatcher.match(plate.contents);
		if (recipe == null) return false;

		var snapshot = plate.contents.copy();
		plate.contents = [];
		plate.dish = new Dish(recipe.id, snapshot);

		// TODO: SoundSystem.play("merge")
		if (player != null) {
			var fb = player.get(ActionFeedback);
			if (fb != null) {
				var args:loc.base.I18nContract.PlaceholderArgs = new haxe.DynamicAccess<String>();
				args.set("name", GameI18n.recipeName(recipe.id));
				fb.set("messages.dish_ready", 2.0, 0x88FF88, args);
			}
		}
		return true;
	}
}
