class_name FloatingSection
extends Control

@export var vertical_speed = 0.5
@export var vertical_intensity = 20.0
@export var horizontal_speed = 1.0
@export var horizontal_intensity = 15

var start_position
var rand

func _ready():
	call_deferred("_initialize_position")
	
func _initialize_position():
	start_position = position
	rand = randf() * 150

func _process(_delta):
	position = start_position + Vector2(cos(Time.get_unix_time_from_system() * horizontal_speed + rand) * horizontal_intensity, sin(Time.get_unix_time_from_system() + rand * vertical_speed) * vertical_intensity)
