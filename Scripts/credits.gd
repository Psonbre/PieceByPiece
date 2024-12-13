extends Node2D

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		SubSystemManager.get_scene_manager().load_main_menu(Vector2(-1,0))
