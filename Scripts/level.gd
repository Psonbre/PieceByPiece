extends Node
class_name Level
@export var world : SceneManager.WORLDS
@export var next_level : PackedScene
func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		SubSystemManager.get_scene_manager().load_level_select(world)
