package game.ui.action;

import game.ui.mvp.IView;

/**
 * Bottom-right contextual HUD. Renders ActionHint rows as "[Key] Label"
 * pairs, one per line. No game logic — render-only.
 */
@:uiComp("action-hud")
class ActionHudView extends h2d.Flow implements h2d.domkit.Object implements IView<ActionHudModel> {
	static var SRC = <action-hud>
		<flow public id="list" layout="vertical"/>
	</action-hud>;

	var font:h2d.Font;
	var rows:Array<h2d.Flow> = [];
	var keyTexts:Array<h2d.Text> = [];
	var labelTexts:Array<h2d.Text> = [];

	public function new(font:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		this.font = font;
	}

	public function render(m:ActionHudModel):Void {
		this.visible = m.visible && m.hints.length > 0;
		if (!this.visible) return;

		ensureRows(m.hints.length);
		for (i in 0...rows.length) {
			rows[i].visible = i < m.hints.length;
			if (i >= m.hints.length) continue;
			var h = m.hints[i];
			keyTexts[i].text = '[${h.key}]';
			labelTexts[i].text = h.progress > 0
				? '${h.label} ${Math.round(h.progress * 100)}%'
				: h.label;
			var color = h.enabled ? 0xFFFFFF : 0x888888;
			keyTexts[i].textColor = h.enabled ? 0xFFD166 : 0x888888;
			labelTexts[i].textColor = color;
		}
	}

	function ensureRows(n:Int):Void {
		while (rows.length < n) addRow();
	}

	function addRow():Void {
		var row = new h2d.Flow(list);
		row.layout = Horizontal;
		row.horizontalSpacing = 8;
		row.verticalAlign = Middle;

		var key = new h2d.Text(font, row);
		key.smooth = true;
		var label = new h2d.Text(font, row);
		label.smooth = true;

		rows.push(row);
		keyTexts.push(key);
		labelTexts.push(label);
	}
}
