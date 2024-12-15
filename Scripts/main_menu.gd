extends Node2D

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause") and SubSystemManager.get_scene_manager().current_screen == self:
		get_tree().quit()
