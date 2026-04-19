package game.ui.action;

/**
 * Pure data row shown by ActionHudView.
 * `key`      — key cap label (e.g. "E" or "Hold E").
 * `label`    — localized action text (ASCII-only until fonts include cyrillic).
 * `enabled`  — false = dimmed hint (contextually known but currently blocked).
 * `progress` — 0..1 charge indicator (0 = not charging).
 */
typedef ActionHint = {
	key:String,
	label:String,
	enabled:Bool,
	progress:Float,
}
