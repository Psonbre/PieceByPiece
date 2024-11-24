extends SceneTree
class_name SubSystemManager

static var instance : SubSystemManager : 
	get() : return Engine.get_main_loop()			
static var scene_manager : SceneManager
static var music_manager: MusicManager
static var sound_manager: SoundManager
static var collectible_manager: CollectibleManager

func _initialize() -> void:
	get_scene_manager()
	if !root.has_node("Intro"):
		get_music_manager()
	
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
	
static func get_collectible_manager() -> CollectibleManager:
	if collectible_manager == null:
		collectible_manager = CollectibleManager.new()
	return collectible_manager
