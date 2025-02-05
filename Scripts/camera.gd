extends Camera2D

var max_zoom := 2.0
var min_zoom := 1.0
var pan_tween : Tween
var target_position := Vector2.ZERO
var target_zoom := Vector2.ONE
const SPEED := 3
func pan(new_position := Vector2.ZERO, new_zoom := Vector2.ONE) :
	if new_zoom.x < min_zoom : new_zoom = Vector2.ONE * min_zoom
	elif new_zoom.x > max_zoom : new_zoom = Vector2.ONE * max_zoom
	
	target_position = new_position
	target_zoom = new_zoom
	
func _process(delta: float) -> void:
	var dragging_piece := PuzzlePiece.dragging_piece
	if dragging_piece : 
		if !Rect2(global_position - (get_viewport_rect().size / zoom) / 2.0, get_viewport_rect().size / zoom).grow(-100).has_point(dragging_piece.global_position) :
			pan(Vector2.ZERO, zoom - (Vector2.ONE * 0.15))
	
	global_position = global_position.move_toward(target_position, global_position.distance_to(target_position) * delta * SPEED)
	zoom = zoom.move_toward(target_zoom, zoom.distance_to(target_zoom) * delta * SPEED)
