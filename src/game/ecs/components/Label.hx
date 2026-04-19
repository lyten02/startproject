package game.ecs.components;

/**
 * Text tag rendered above an entity (world-space, follows Transform).
 * `key` holds the i18n dotted path (e.g. "ui.stations.sink"); LabelSystem
 * resolves it through I18n.t each time the language changes.
 */
class Label implements Component {
	public var key:String;
	public var color:Int;
	public var display:h2d.Text; // set by LabelSystem when spawned

	public function new(key:String, color:Int = 0xFFFFFF) {
		this.key   = key;
		this.color = color;
	}
}
