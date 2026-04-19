package game.ecs;

import haxe.ds.StringMap;

/**
 * Entity = id + typed component bag. Accessed via Entity.get(Class).
 * Testable without engine (components are plain classes).
 */
class Entity {
	public var id(default, null):Int;
	var components:StringMap<Component>;

	public function new(id:Int) {
		this.id = id;
		this.components = new StringMap();
	}

	public function add<T:Component>(c:T):T {
		components.set(Type.getClassName(Type.getClass(c)), c);
		return c;
	}

	public function get<T:Component>(cls:Class<T>):Null<T> {
		var c = components.get(Type.getClassName(cls));
		return cast c;
	}

	public inline function has<T:Component>(cls:Class<T>):Bool {
		return components.exists(Type.getClassName(cls));
	}

	public function remove<T:Component>(cls:Class<T>):Void {
		components.remove(Type.getClassName(cls));
	}
}
