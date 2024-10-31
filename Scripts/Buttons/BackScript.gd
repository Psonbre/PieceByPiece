extends Button

func _on_pressed() -> void:
	SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/button_click.ogg", 0, 1)
	get_tree().root.get_node("Game").load_main_menu()
