extends Button

func _on_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), 0, 1)
	get_tree().quit()
	focus_mode = FocusMode.FOCUS_NONE

func _on_mouse_entered():
	scale = 1.1 * Vector2.ONE


func _on_mouse_exited():
	scale = 1.0 * Vector2.ONE
