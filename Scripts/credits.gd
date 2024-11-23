extends Node2D

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		SubSystemManager.get_game_manager().load_scene("res://Scenes/Menus/MainMenu.tscn", Vector2(-1,0))
