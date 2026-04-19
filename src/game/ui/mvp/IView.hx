package game.ui.mvp;

/** View renders a Model; no logic. Model type is component-specific. */
interface IView<TModel> {
	function render(model:TModel):Void;
}
