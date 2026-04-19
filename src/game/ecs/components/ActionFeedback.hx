package game.ecs.components;

import loc.base.I18nContract.PlaceholderArgs;

/**
 * Transient status message attached to the player after a failed/successful
 * interaction attempt. ActionBarPresenter reads + decays it each frame and
 * resolves `msgKey` through I18n at render time (stays reactive to language).
 * `ttl <= 0` means nothing to show.
 */
class ActionFeedback implements Component {
	public var msgKey:String = "";
	public var msgArgs:PlaceholderArgs = null;
	public var ttl:Float  = 0;
	public var total:Float = 0;
	public var color:Int   = 0xFFFFFF;

	public function new() {}

	public inline function set(msgKey:String, ttl:Float, color:Int, ?args:PlaceholderArgs):Void {
		this.msgKey  = msgKey;
		this.msgArgs = args;
		this.ttl     = ttl;
		this.total   = ttl;
		this.color   = color;
	}
}
