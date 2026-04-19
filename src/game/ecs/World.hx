package game.ecs;

/** Entity registry + query. */
class World {
	public var entities(default, null):Array<Entity>;
	var nextId:Int = 0;

	public function new() {
		this.entities = [];
	}

	public function create():Entity {
		var e = new Entity(nextId++);
		entities.push(e);
		return e;
	}

	public function destroy(e:Entity):Void {
		entities.remove(e);
	}

	/** Returns all entities carrying the given component. */
	public function query<T:Component>(cls:Class<T>):Array<Entity> {
		var out = [];
		for (e in entities) if (e.has(cls)) out.push(e);
		return out;
	}

	public inline function count():Int return entities.length;
}
