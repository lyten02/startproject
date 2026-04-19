package fixtures;

import loc.base.LocaleId;

class GameplayI18nStub implements I18nTestStub {
	public function new() {}

	public function locale():LocaleId return LocaleId.EN;

	public function strings():Map<String, String> {
		var m = new Map<String, String>();

		// actions.*
		m.set("actions.catch", "Catch");
		m.set("actions.pickup", "Pickup");
		m.set("actions.take_top", "Take top");
		m.set("actions.take_last", "Take last");
		m.set("actions.take", "Take {item}");
		m.set("actions.take_plate", "Take plate");
		m.set("actions.chop", "Chop");
		m.set("actions.wash", "Wash");
		m.set("actions.trash", "Trash");
		m.set("actions.scoop", "Scoop");
		m.set("actions.stack", "Stack");
		m.set("actions.onto_plate", "Onto plate");
		m.set("actions.place", "Place");
		m.set("actions.drop_last", "Drop last");
		m.set("actions.throw", "Throw");
		m.set("actions.hold_prompt", "Hold {key}");

		// ingredients.*
		m.set("ingredients.bread", "Bread");
		m.set("ingredients.meat", "Meat");
		m.set("ingredients.cheese", "Cheese");
		m.set("ingredients.tomato", "Tomato");
		m.set("ingredients.lettuce", "Lettuce");
		m.set("ingredients.onion", "Onion");
		m.set("ingredients.cucumber", "Cucumber");

		return m;
	}
}
