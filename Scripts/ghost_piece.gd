extends PuzzlePiece
class_name GhostPiece

var last_displayed_position : Vector2 = Vector2.INF
var valid_placement := false
var displayed := false

@onready var visual_shape = $VisualShape
@onready var visual_right_connector = $VisualShape/Connectors/RightConnector
@onready var visual_left_connector = $VisualShape/Connectors/LeftConnector
@onready var visual_top_connector = $VisualShape/Connectors/TopConnector
@onready var visual_bottom_connector = $VisualShape/Connectors/BottomConnector

func _ready():
	start_drag_position = position
	default_scale = scale
	
func display(piece : PuzzlePiece, actual_global_position : Vector2, visual_global_position : Vector2, visual_global_rotation : float):
	if last_displayed_position == actual_global_position : return
	
	last_displayed_position = actual_global_position
	shape.hole_radius = piece.shape.hole_radius
	shape.hole_segments = piece.shape.hole_segments
	right_connector.type = piece.right_connector.type
	left_connector.type = piece.left_connector.type
	top_connector.type = piece.top_connector.type
	bottom_connector.type = piece.bottom_connector.type
	visual_shape.hole_radius = piece.shape.hole_radius
	visual_shape.hole_segments = piece.shape.hole_segments
	visual_right_connector.type = piece.right_connector.type
	visual_left_connector.type = piece.left_connector.type
	visual_top_connector.type = piece.top_connector.type
	visual_bottom_connector.type = piece.bottom_connector.type
	global_position = actual_global_position
	visual_shape.global_position = visual_global_position
	visual_shape.global_rotation = visual_global_rotation
	outline.position = visual_shape.position
	outline.rotation = visual_shape.rotation
	
	#idk why I need to do this but removing them breaks the code so... 🤷‍♂️
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	
	if all_overlapping_pieces_have_compatible_overlapping_connectors() && all_connectors_can_be_dropped() :
		outline.material.set_shader_parameter('color', Vector4(1,1,1,0.5))
		valid_placement = true
	else :
		outline.material.set_shader_parameter('color', Vector4(1,0,0,0.5))
		valid_placement = false
		all_overlapping_pieces_have_compatible_overlapping_connectors() && all_connectors_can_be_dropped()
		
	visual_shape.visible = true
	outline.visible = true
	displayed = true

func hide_display():
	displayed = false
	last_displayed_position = Vector2.INF
	global_position = Vector2.INF
	valid_placement = true
	visual_shape.visible = false
	outline.visible = false

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
