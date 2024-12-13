extends Camera2D

var max_zoom := 2.0
var min_zoom := 1.0
var target_position = Vector2.ZERO
var target_zoom := Vector2.ONE :
	set(value) :
		target_zoom = value
		if target_zoom.x < min_zoom : target_zoom = Vector2.ONE * min_zoom
		elif target_zoom.x > max_zoom : target_zoom = Vector2.ONE * max_zoom
		 
func _process(delta):
	global_position = global_position.move_toward(target_position, global_position.distance_to(target_position) * delta)
	zoom = zoom.move_toward(target_zoom, zoom.distance_to(target_zoom) * delta * 2.0)
