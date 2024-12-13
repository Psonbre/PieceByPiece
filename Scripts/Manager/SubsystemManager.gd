extends SceneTree
class_name SubSystemManager

static var instance: SubSystemManager = null
static var scene_manager: SceneManager = null
static var music_manager: MusicManager = null
static var sound_manager: SoundManager = null
static var settings_manager: SettingsManager = null


# Initialize the singleton instance
func _initialize() -> void:
	instance = Engine.get_main_loop() as SubSystemManager

# Get the SubsystemManager singleton instance
static func get_SubsystemManager() -> SubSystemManager:
	if instance == null:
		instance = Engine.get_main_loop() as SubSystemManager
	return instance

# Get the LevelManager instance
static func get_scene_manager() -> SceneManager:
	if scene_manager == null:
		var level_manager_scene = load("res://Scenes/Manager/SceneManager.tscn")
		scene_manager = level_manager_scene.instantiate()
		get_SubsystemManager().root.add_child(scene_manager)
	return scene_manager
	
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
	
# Get the SettingsManager instance
static func get_settings_manager() -> SettingsManager:
	if settings_manager == null:
		settings_manager = SettingsManager.new()
	return settings_manager
