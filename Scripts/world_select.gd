extends Node2D
@onready var tree = $Tree

func _input(event):
	if Input.is_action_just_pressed("Pause"):
		get_tree().get_first_node_in_group("GameManager").load_scene("res://Scenes/Menus/MainMenu.tscn", Vector2(0,-1))
		tree.target_position = Vector2(0,1280)
