extends Area2D

var start_position
@export var vertical_speed = 0.5
@export var vertical_intensity = 20.0
@export var horizontal_speed = 1.0
@export var horizontal_intensity = 15.0

var rand

func _ready():
	start_position = position
	rand = randf() * 150

func _process(delta):
	position = start_position + Vector2(cos(Time.get_unix_time_from_system() * horizontal_speed + rand) * horizontal_intensity, sin(Time.get_unix_time_from_system() + rand * vertical_speed) * vertical_intensity)
	pass

func _on_body_entered(body):
	if body is Player and body.is_physics_processing() && !Player.has_collectible:
		Player.has_collectible = true
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/winJingle.ogg", -5)
		SubsystemManager.get_collectible_manager().add_piece()
		visible = false
