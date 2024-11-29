extends Area2D
class_name Collectible

const COLLECT_JINGLE = preload("res://Assets/Sounds/winJingle.ogg")
var start_position : Vector2
@export var vertical_speed = 0.5
@export var vertical_intensity = 20.0
@export var horizontal_speed = 1.0
@export var horizontal_intensity = 15.0
@onready var collision_shape_2d = $CollisionShape2D
var rand := 0.0

func _ready():
	collision_shape_2d.disabled = !visible
	start_position = position
	rand = randf() * 150

func _process(_delta):
	position = start_position + Vector2(cos(Time.get_unix_time_from_system() * horizontal_speed + rand) * horizontal_intensity, sin(Time.get_unix_time_from_system() + rand * vertical_speed) * vertical_intensity)

func _on_body_entered(body):
	if body is Player and body.is_physics_processing() && !get_parent().get_parent().is_dragging && !Player.has_collectible && SubSystemManager.get_scene_manager().old_screen == null:
		Player.has_collectible = true
		SubSystemManager.get_sound_manager().play_sound(COLLECT_JINGLE, -5)
		visible = false
