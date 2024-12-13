extends Button

@export var scroll_direction := Vector2(1,0)

func _on_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
	SubSystemManager.get_scene_manager().load_main_menu(scroll_direction)
