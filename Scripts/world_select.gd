extends Node2D
@onready var tree = $Tree

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		SubSystemManager.get_game_manager().load_scene("res://Scenes/Menus/MainMenu.tscn", Vector2(0,-1))
		tree.target_position = Vector2(0,1280)
