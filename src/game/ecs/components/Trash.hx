package game.ecs.components;

/**
 * Marker: entity is a bin. Held items dropped on its cell (interact) and
 * airborne items overlapping its AABB (throw) get destroyed.
 */
class Trash implements Component {
	public function new() {}
}
