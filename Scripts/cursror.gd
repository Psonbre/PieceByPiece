extends Node2D

func _process(delta: float) -> void:
	global_position = get_global_mouse_position()
	scale = Vector2.ONE / get_viewport().get_camera_2d().zoom
