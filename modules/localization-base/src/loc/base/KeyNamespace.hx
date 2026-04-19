package loc.base;

enum abstract KeyNamespace(String) to String {
	var Ui = "ui";
	var Actions = "actions";
	var Recipes = "recipes";
	var Ingredients = "ingredients";
	var Messages = "messages";

	public static final ALL:Array<KeyNamespace> = [Ui, Actions, Recipes, Ingredients, Messages];
}
