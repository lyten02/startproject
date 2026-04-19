package game.ecs.components;

/**
 * Marker: this Surface is a "serve" window. OrderDeliverySystem matches
 * plates with a finished Dish resting on cells of this surface against the
 * active OrderQueue and completes the first matching order.
 */
class ServeWindow implements Component {
	public function new() {}
}
