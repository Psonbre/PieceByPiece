extends Node
class_name LevelManager

@onready var sceneTransition = $SceneTransition
var new_packed_scene = null

func reload_level() -> void:
	load_level(SubsystemManager.get_SubsystemManager().current_scene.scene_file_path)

func load_level(level_name: String) -> void:
	var packed_scene: PackedScene = ResourceLoader.load(level_name)

	if packed_scene != null:
		new_packed_scene = packed_scene
		_on_scene_transition_transitioned()
		#sceneTransition.fade_in()

func _on_scene_transition_transitioned() -> void:
	
		var new_level: Node = new_packed_scene.instantiate()
		SubsystemManager.get_SubsystemManager().root.add_child(new_level)

		var current_scene: Node = SubsystemManager.get_SubsystemManager().current_scene
		if current_scene != null:
			current_scene.queue_free() # Safely remove the current scene after the new one is added

		# Set the new scene as the active one
		SubsystemManager.get_SubsystemManager().current_scene = new_level
		new_packed_scene = null
		sceneTransition.fade_out()
