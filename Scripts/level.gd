extends Node

@export var level_select_scene : PackedScene

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		SubSystemManager.get_scene_manager().load_scene(level_select_scene)
