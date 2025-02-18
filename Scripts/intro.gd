extends Node2D

@onready var player = $VideoStreamPlayer
@onready var godot = $GodotIcon
@onready var timer = $Timer

@export var godotIconDuration : float = 2
@export var fadeInDuration : float = 1


func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(godot, "modulate:a", 1, fadeInDuration).set_ease(Tween.EASE_OUT)
	timer.start(godotIconDuration)


func _process(_delta):
	if Input.is_action_just_pressed("skip_intro"):
		show_main_menu()

func _on_video_stream_player_finished():
	show_main_menu()


func _on_timer_timeout() -> void:
	var tween := create_tween()
	player.play()
	tween.tween_property(godot, "modulate:a", 0, fadeInDuration).set_ease(Tween.EASE_OUT)
	tween.tween_property(player, "modulate:a", 1, fadeInDuration).set_ease(Tween.EASE_OUT)

func show_main_menu():
	SubSystemManager.get_music_manager().play_music(preload("res://Assets/Music/Music.mp3"))
	SubSystemManager.get_scene_manager().load_main_menu(Vector2(0,1))
	SubSystemManager.get_hud_manager()._show_hud()
	queue_free()
