extends Node2D

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		SubSystemManager.get_scene_manager().load_scene(preload("res://Scenes/Menus/MainMenu.tscn"), Vector2(-1,0))
