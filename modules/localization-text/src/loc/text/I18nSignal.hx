package loc.text;

import loc.base.LocEvent;

class I18nSignal {
	var listeners:Array<LocEvent->Void> = [];

	public function new() {}

	public function listen(cb:LocEvent->Void):Void->Void {
		listeners.push(cb);
		return () -> unlisten(cb);
	}

	public function unlisten(cb:LocEvent->Void):Void {
		listeners.remove(cb);
	}

	public function dispatch(e:LocEvent):Void {
		var snap = listeners.copy();
		for (cb in snap) cb(e);
	}

	public inline function listenerCount():Int return listeners.length;
}
