extends Node

var is_paused : bool = false
@onready var pausePanel = $PausePanel

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		toggle_pause()

func _on_pause_button_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound("res://Assets/Sounds/button_click.ogg", 0, 1)
	toggle_pause()
	
func _on_resume_button_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound("res://Assets/Sounds/button_click.ogg", 0, 1)
	toggle_pause()

func _on_restart_button_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound("res://Assets/Sounds/button_click.ogg", 0, 1)
	toggle_pause()
	SubSystemManager.get_game_manager().reset_level()
	
func _on_quit_button_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound("res://Assets/Sounds/button_click.ogg", 0, 1)
	toggle_pause()
	SubSystemManager.get_game_manager().load_scene("res://Scenes/MainMenu.tscn", Vector2(0, -1))

func toggle_pause() -> void:
	if !is_paused:
		is_paused = true
		Engine.time_scale = 0
		pausePanel.visible = true
	else:
		is_paused = false
		Engine.time_scale = 1
		pausePanel.visible = false
	
