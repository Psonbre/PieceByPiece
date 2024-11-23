extends Node2D

func _process(_delta):
	if Input.is_action_just_pressed("skip_intro"):
		var game = load("res://Scenes/game.tscn").instantiate()
		get_tree().root.add_child(game)
		queue_free()

func _on_video_stream_player_finished():
		var game = load("res://Scenes/game.tscn").instantiate()
		get_tree().root.add_child(game)
		queue_free()
