extends SceneTree
class_name SubSystemManager

static var instance : SubSystemManager : 
	get() : return Engine.get_main_loop()			
static var scene_manager : SceneManager
static var music_manager: MusicManager
static var sound_manager: SoundManager
static var settings_manager: SettingsManager
static var config_file_manager: ConfigFileManager

func _initialize() -> void:
	get_config_file_manager()._load_config()
	get_scene_manager()
	if !root.has_node("Intro"):
		get_music_manager()
	SaveManager._load_from_file()
	
static func get_scene_manager() -> SceneManager:
	if scene_manager == null:
		scene_manager = instance.get_first_node_in_group("SceneManager")
		if scene_manager == null :
			scene_manager = preload("res://Scenes/Manager/SceneManager.tscn").instantiate()
			instance.root.add_child(scene_manager)
	return scene_manager

static func get_music_manager() -> MusicManager:
	if music_manager == null:
		var music_manager_scene = preload("res://Scenes/Manager/MusicManager.tscn")
		music_manager = music_manager_scene.instantiate()
		instance.root.add_child(music_manager)
	return music_manager

static func get_sound_manager() -> SoundManager:
	if sound_manager == null:
		var sound_manager_scene = preload("res://Scenes/Manager/SoundManager.tscn")
		sound_manager = sound_manager_scene.instantiate()
		instance.root.add_child(sound_manager)
	return sound_manager
	
static func get_settings_manager() -> SettingsManager:
	if settings_manager == null:
		settings_manager = SettingsManager.new()
	return settings_manager
		
static func get_config_file_manager() -> ConfigFileManager:
	if config_file_manager == null:
		config_file_manager = ConfigFileManager.new()
	return config_file_manager
