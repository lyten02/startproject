package game.ui.score;

import game.ui.mvp.IView;
import loc.text.I18n;

/**
 * Top-right session score: served count, failed count, money. Render-only;
 * labels are resolved through I18n every frame so language switches are
 * reflected without extra plumbing.
 */
@:uiComp("score-hud")
class ScoreHudView extends h2d.Flow implements h2d.domkit.Object implements IView<ScoreHudModel> {
	static var SRC = <score-hud>
		<text public id="servedText" class="served" text={""}/>
		<text public id="failedText" class="failed" text={""}/>
		<text public id="moneyText"  class="money"  text={""}/>
	</score-hud>;

	public function new(font:h2d.Font, ?parent) {
		super(parent);
		initComponent();
		for (t in [servedText, failedText, moneyText]) {
			t.font = font;
			t.smooth = true;
		}
	}

	public function render(m:ScoreHudModel):Void {
		var served:haxe.DynamicAccess<String> = {}; served.set("n", Std.string(m.served));
		var failed:haxe.DynamicAccess<String> = {}; failed.set("n", Std.string(m.failed));
		var money:haxe.DynamicAccess<String>  = {}; money.set("n",  Std.string(m.money));
		servedText.text = I18n.t("ui.score.served", served);
		failedText.text = I18n.t("ui.score.failed", failed);
		moneyText.text  = I18n.t("ui.score.money",  money);
	}
}
