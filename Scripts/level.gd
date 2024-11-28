extends Node
class_name Level
@export var level_select_world : SceneManager.WORLDS

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		SubSystemManager.get_scene_manager().load_level_select(level_select_world)
