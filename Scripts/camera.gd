extends Camera2D

var target_position = Vector2.ZERO
var target_zoom = Vector2.ONE

func _process(delta):
	global_position = global_position.move_toward(target_position, global_position.distance_to(target_position) * delta)
	zoom = zoom.move_toward(target_zoom, zoom.distance_to(target_zoom) * delta)
