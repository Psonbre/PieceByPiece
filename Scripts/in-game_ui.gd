extends Control

var default_scale : Vector2

func _ready() -> void:
	default_scale = scale * get_viewport().get_camera_2d().zoom

func _process(delta: float) -> void:
	var target_scale := default_scale / get_viewport().get_camera_2d().zoom
	scale = scale.move_toward(target_scale, abs(scale.x - target_scale.x) * 10.0 * delta) 
