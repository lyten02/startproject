package game.ui.orders;

import game.ui.mvp.IView;
import loc.text.I18n;

/**
 * Top-center horizontal strip of order cards. Creates/hides OrderCardView
 * children to match the model; the presenter owns data and localization,
 * the view only pushes it into sub-views.
 */
@:uiComp("order-queue")
class OrderQueueView extends h2d.Flow implements h2d.domkit.Object implements IView<OrderQueueModel> {
	static var SRC = <order-queue>
		<flow public id="list" layout="horizontal"/>
	</order-queue>;

	var font:h2d.Font;
	var cards:Array<OrderCardView> = [];

	public function new(font:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		this.font = font;
	}

	public function render(m:OrderQueueModel):Void {
		this.visible = m.visible && m.entries.length > 0;
		if (!this.visible) return;
		ensureCards(m.entries.length);
		for (i in 0...cards.length) {
			var show = i < m.entries.length;
			cards[i].visible = show;
			if (!show) continue;
			var e = m.entries[i];
			cards[i].apply(I18n.t(e.dishKey), e.patienceRatio, e.barColor, e.ingredients);
		}
	}

	function ensureCards(n:Int):Void {
		while (cards.length < n) cards.push(new OrderCardView(font, list));
	}
}
