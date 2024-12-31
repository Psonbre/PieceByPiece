extends Button

func _on_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
	get_tree().quit()
	focus_mode = FocusMode.FOCUS_NONE

func _on_mouse_entered():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.2, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_mouse_exited():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.0, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
