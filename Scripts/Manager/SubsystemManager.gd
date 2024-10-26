extends SceneTree
class_name SubsystemManager

static var instance: SubsystemManager = null
static var level_manager: LevelManager = null
static var music_manager: MusicManager = null
static var sound_manager: SoundManager = null
static var collectible_manager: CollectibleManager = null
static var settings_manager: SettingsManager = null


# Initialize the singleton instance
func _initialize() -> void:
	instance = Engine.get_main_loop() as SubsystemManager

# Get the SubsystemManager singleton instance
static func get_SubsystemManager() -> SubsystemManager:
	if instance == null:
		instance = Engine.get_main_loop() as SubsystemManager
	return instance

# Get the LevelManager instance
static func get_level_manager() -> LevelManager:
	if level_manager == null:
		var level_manager_scene = load("res://Scenes/Manager/SceneManager.tscn")
		level_manager = level_manager_scene.instantiate()
		get_SubsystemManager().root.add_child(level_manager)
	return level_manager
	
# Get the MusicManager instance
static func get_music_manager() -> MusicManager:
	if music_manager == null:
		var music_manager_scene = load("res://Scenes/Manager/MusicManager.tscn")
		music_manager = music_manager_scene.instantiate()
		get_SubsystemManager().root.add_child(music_manager)
	return music_manager

# Get the MusicManager instance
static func get_sound_manager() -> SoundManager:
	if sound_manager == null:
		var sound_manager_scene = load("res://Scenes/Manager/SoundManager.tscn")
		sound_manager = sound_manager_scene.instantiate()
		get_SubsystemManager().root.add_child(sound_manager)
	return sound_manager
	
# Get the CollectibleManager instance
static func get_collectible_manager() -> CollectibleManager:
	if collectible_manager == null:
		collectible_manager = CollectibleManager.new()
	return collectible_manager
	
# Get the SettingsManager instance
static func get_settings_manager() -> SettingsManager:
	if settings_manager == null:
		settings_manager = SettingsManager.new()
	return settings_manager
