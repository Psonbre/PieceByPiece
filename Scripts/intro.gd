extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("skip_intro"):
		SubsystemManager.get_level_manager().load_level("res://Scenes/Game.tscn")

func _on_video_stream_player_finished():
	SubsystemManager.get_level_manager().load_level("res://Scenes/Game.tscn")
