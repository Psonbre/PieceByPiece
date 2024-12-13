extends FloatingUI

@export var scroll_direction := Vector2(1,0)

func _on_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
	SubSystemManager.get_scene_manager().load_main_menu(scroll_direction)

func _on_mouse_entered():
	scale = 1.1 * Vector2.ONE


func _on_mouse_exited():
	scale = 1.0 * Vector2.ONE
