extends Node2D

func _process(_delta):
	if Input.is_action_just_pressed("skip_intro"):
		SubSystemManager.get_music_manager().play_music(preload("res://Assets/Music/Music.mp3"))
		SubSystemManager.get_scene_manager().load_main_menu(Vector2(0,1))
		queue_free()

func _on_video_stream_player_finished():
		SubSystemManager.get_music_manager().play_music(preload("res://Assets/Music/Music.mp3"))
		SubSystemManager.get_scene_manager().load_main_menu(Vector2(0,1))
		queue_free()
