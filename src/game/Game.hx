package game;

import starter.IGame;
import game.states.IGameState;
import game.states.GameplayState;
import game.input.InputBindings;
import game.render.SceneScaler;
import game.ui.orient.OrientPresenter;
import game.ui.orient.OrientView;
import loc.base.LocaleId;
import loc.text.I18n;
import loc.text.config.ConfigManager;
import loc.text.font.FontRegistry;

/**
 * Root container. Owns:
 *   - InputBindings (shared by states)
 *   - Domkit Style (shared)
 *   - Active IGameState
 *   - Portrait-mode OrientView overlay (always on top, above all states)
 *
 * When in portrait, state updates are paused.
 */
class Game implements IGame {
	public var app(default, null):hxd.App;
	public var input(default, null):InputBindings;
	public var style(default, null):h2d.domkit.Style;

	var currentState:IGameState;
	var scaler:SceneScaler;

	// Orientation overlay.
	var orientRoot:h2d.Object;
	var orientBg:h2d.Bitmap;
	var orientView:OrientView;
	var orientPresenter:OrientPresenter;

	public function new() {}

	public function init(app:hxd.App):Void {
		var cfg = ConfigManager.load();
		I18n.init(LocaleId.EN);
		var requested = LocaleId.parse(cfg.language);
		if ((requested : String) != (LocaleId.EN : String)) {
			I18n.setLanguage(requested);
		}

		this.app    = app;
		this.input  = new InputBindings();
		this.scaler = new SceneScaler(1080);

		app.s2d.scaleMode = Resize;

		this.style = new h2d.domkit.Style();
		this.style.load(hxd.Res.ui.style);

		switchState(new GameplayState(this));
		buildOrientOverlay();
	}

	public function update(dt:Float):Void {
		input.update(dt);
		style.sync(dt);

		var win = hxd.Window.getInstance();
		if (win.height > win.width) showOrientAndPause() else hideOrient(dt);
	}

	public function dispose():Void {
		if (orientPresenter != null) { orientPresenter.dispose(); orientPresenter = null; }
		if (orientView != null)      { style.removeObject(orientView); orientView = null; }
		if (currentState != null)    { currentState.exit(); currentState = null; }
		if (input != null)           { input.dispose(); input = null; }
	}

	public function switchState(next:IGameState):Void {
		if (currentState != null) currentState.exit();
		currentState = next;
		currentState.enter();
		if (orientRoot != null) app.s2d.addChild(orientRoot);
	}

	function showOrientAndPause():Void {
		scaler.sync(app.s2d.width, app.s2d.height);
		orientBg.scaleX = app.s2d.width;
		orientBg.scaleY = app.s2d.height;
		orientView.setScale(scaler.scale);
		orientView.x = Math.round((app.s2d.width  - orientView.innerWidth  * scaler.scale) * 0.5);
		orientView.y = Math.round((app.s2d.height - orientView.innerHeight * scaler.scale) * 0.5);
		orientRoot.visible = true;
	}

	function hideOrient(dt:Float):Void {
		orientRoot.visible = false;
		if (currentState != null) currentState.update(dt);
	}

	function buildOrientOverlay():Void {
		orientRoot = new h2d.Object(app.s2d);
		orientBg   = new h2d.Bitmap(h2d.Tile.fromColor(0x000000, 1, 1, 0.88), orientRoot);

		orientView = new OrientView(FontRegistry.get(72), FontRegistry.get(36), orientRoot);
		style.addObject(orientView);
		orientPresenter = new OrientPresenter(orientView, "ui.orient.main", "ui.orient.sub");
		orientRoot.visible = false;
	}
}
