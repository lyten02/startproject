package starter.save;

#if gamepush
import gamepush.GamePush;
#end

/**
 * Generic cloud save manager for GamePush.
 *
 * Usage:
 * ```haxe
 * typedef MySaveData = {
 *   var score:Int;
 *   var level:Int;
 * }
 *
 * var manager = new CloudSaveManager<MySaveData>(
 *   {score: 0, level: 1},
 *   ["score", "level"]
 * );
 *
 * manager.load(() -> {
 *   trace("Score: " + manager.data.score);
 * });
 *
 * manager.data.score = 100;
 * manager.save();
 * ```
 */
class CloudSaveManager<T> {
	public var data(default, null):T;

	var defaults:T;
	var fieldNames:Array<String>;

	/**
	 * @param defaults Default values for save data
	 * @param fieldNames Field names to sync with GamePush (use kebab-case for cloud keys)
	 */
	public function new(defaults:T, fieldNames:Array<String>) {
		this.defaults = defaults;
		this.fieldNames = fieldNames;
		this.data = cloneDefaults();
	}

	/**
	 * Load data from cloud (priority: cloud → defaults).
	 * Call this AFTER GamePush player.ready!
	 */
	public function load(onComplete:Void->Void):Void {
		#if gamepush
		loadFromCloud(onComplete);
		#else
		trace("[CloudSaveManager] GamePush disabled, using defaults");
		data = cloneDefaults();
		onComplete();
		#end
	}

	/**
	 * Save data to cloud only (no localStorage).
	 */
	public function save(onComplete:Null<Void->Void> = null):Void {
		#if gamepush
		syncToCloud(onComplete);
		#else
		trace("[CloudSaveManager] GamePush disabled, data not persisted");
		if (onComplete != null) onComplete();
		#end
	}

	/**
	 * Reset to defaults and sync to cloud.
	 */
	public function reset(onComplete:Null<Void->Void> = null):Void {
		data = cloneDefaults();
		save(onComplete);
	}

	/**
	 * Reload from cloud (use if data changed on server).
	 */
	public function reload(onComplete:Null<Void->Void> = null):Void {
		#if gamepush
		if (isGamePushAvailable()) {
			untyped __js__("
				window.gamePushSDK.player.load().then(function(success) {
					if (success) {
						{0}.load({1});
					} else if ({1}) {
						{1}();
					}
				});
			", this, onComplete);
			return;
		}
		#end
		data = cloneDefaults();
		if (onComplete != null) onComplete();
	}

	// ===== Private Methods =====

	#if gamepush
	function loadFromCloud(onComplete:Void->Void):Void {
		if (!isGamePushAvailable()) {
			trace("[CloudSaveManager] GamePush not available, using defaults");
			data = cloneDefaults();
			onComplete();
			return;
		}

		var self = this;
		untyped __js__("
			(function() {
				var player = window.gamePushSDK.player;

				try {
					var firstField = {0}[0];
					var hasCloudData = player.has(firstField);

					if (hasCloudData) {
						console.log('[CloudSaveManager] Loading from cloud...');

						// Load all fields
						{0}.forEach(function(field) {
							var cloudKey = field.replace(/([A-Z])/g, '-$1').toLowerCase();
							var value = player.get(cloudKey);
							if (value != null) {
								{1}.data[field] = value;
								console.log('  - ' + cloudKey + ':', value);
							}
						});

						console.log('[CloudSaveManager] Cloud data loaded');
					} else {
						console.log('[CloudSaveManager] No cloud data, using defaults');
						{1}.data = {1}.cloneDefaults();

						// Sync defaults to cloud
						console.log('[CloudSaveManager] Syncing defaults to cloud...');
						{1}.syncToCloud(function() {
							console.log('[CloudSaveManager] Defaults synced');
						});
					}
				} catch (e) {
					console.error('[CloudSaveManager] Error loading:', e);
					{1}.data = {1}.cloneDefaults();
				}

				{2}();
			})();
		", fieldNames, self, onComplete);
	}

	function syncToCloud(onComplete:Null<Void->Void>):Void {
		if (!isGamePushAvailable()) {
			trace("[CloudSaveManager] GamePush not available, skipping sync");
			if (onComplete != null) onComplete();
			return;
		}

		var self = this;
		untyped __js__("
			(function() {
				var player = window.gamePushSDK.player;

				try {
					// Set all fields
					{0}.forEach(function(field) {
						var cloudKey = field.replace(/([A-Z])/g, '-$1').toLowerCase();
						var value = {1}.data[field];
						player.set(cloudKey, value);
					});

					// Sync to server
					player.sync().then(function(success) {
						if (success) {
							console.log('[CloudSaveManager] Sync successful');
						} else {
							console.error('[CloudSaveManager] Sync failed');
						}
						if ({2}) {2}();
					});
				} catch (e) {
					console.error('[CloudSaveManager] Error syncing:', e);
					if ({2}) {2}();
				}
			})();
		", fieldNames, self, onComplete);
	}

	function isGamePushAvailable():Bool {
		return untyped __js__("typeof window !== 'undefined' && window.gamePushSDK && window.gamePushSDK.player");
	}
	#end

	function cloneDefaults():T {
		// Create a shallow copy of defaults
		var copy:Dynamic = {};
		for (field in fieldNames) {
			Reflect.setField(copy, field, Reflect.field(defaults, field));
		}
		return cast copy;
	}
}
