extends PuzzlePiece
class_name GhostPiece

var last_displayed_position : Vector2 = Vector2.INF

func display(piece : PuzzlePiece, display_global_position : Vector2):
	if last_displayed_position == display_global_position : return
	
	last_displayed_position = display_global_position
	visible = true
	shape.hole_radius = piece.shape.hole_radius
	shape.hole_segments = piece.shape.hole_segments
	right_connector.type = piece.right_connector.type
	left_connector.type = piece.left_connector.type
	top_connector.type = piece.top_connector.type
	bottom_connector.type = piece.bottom_connector.type
	global_position = display_global_position
	if all_overlapping_pieces_have_compatible_overlapping_connectors() && all_connectors_can_be_dropped() :
		outline.material.set_shader_parameter('color', Vector4(1,1,1,0.5))
	else :
		outline.material.set_shader_parameter('color', Vector4(1,0,0,0.5))

func hide_display():
	last_displayed_position = Vector2.INF
	visible = false

func _process(_delta):
	pass
	
func _on_mouse_entered():
	pass

func _on_mouse_exited():
	pass

func _on_body_entered(_player):
	pass

func _on_body_exited(_player):
	pass
