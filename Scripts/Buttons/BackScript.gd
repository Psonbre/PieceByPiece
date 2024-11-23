extends Button

@export var scroll_direction := Vector2(1,0)

func _on_pressed() -> void:
	SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/button_click.ogg", 0, 1)
	get_tree().root.get_node("Game").load_scene("res://Scenes/Menus/MainMenu.tscn", scroll_direction)
