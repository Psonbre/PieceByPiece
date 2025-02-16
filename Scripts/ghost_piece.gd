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
	visible = true
	hide_display()
	start_drag_position = position
	default_scale = scale
	update_transform()
	
func display(piece : PuzzlePiece, actual_global_position : Vector2, actual_global_rotation : float, visual_global_position : Vector2, visual_global_rotation : float):
	if last_displayed_position == actual_global_position : return
	
	last_displayed_position = actual_global_position
	shape.connector_radius = piece.shape.connector_radius
	shape.connector_segments = piece.shape.connector_segments
	right_connector.type = piece.right_connector.type
	left_connector.type = piece.left_connector.type
	top_connector.type = piece.top_connector.type
	bottom_connector.type = piece.bottom_connector.type
	right_connector.shape = piece.right_connector.shape
	left_connector.shape = piece.left_connector.shape
	top_connector.shape = piece.top_connector.shape
	bottom_connector.shape = piece.bottom_connector.shape
	visual_shape.connector_radius = piece.shape.connector_radius
	visual_shape.connector_segments = piece.shape.connector_segments
	visual_right_connector.type = piece.right_connector.type
	visual_left_connector.type = piece.left_connector.type
	visual_top_connector.type = piece.top_connector.type
	visual_bottom_connector.type = piece.bottom_connector.type
	visual_right_connector.shape = piece.right_connector.shape
	visual_left_connector.shape = piece.left_connector.shape
	visual_top_connector.shape = piece.top_connector.shape
	visual_bottom_connector.shape = piece.bottom_connector.shape
	global_position = actual_global_position
	global_rotation = actual_global_rotation
	visual_shape.global_position = visual_global_position
	visual_shape.global_rotation = visual_global_rotation
	outline.position = visual_shape.position
	outline.rotation = visual_shape.rotation
	
	update_placement_validity()
	connection_group.add_member(piece)
	
func update_placement_validity():
	update_transform()
	if get_first_compatible_overlapping_connector() == null :
		hide_display()
		return
		
	update_connection_group()
	
	outline.material.set_shader_parameter('color', Vector4(1,1,1,0.5))
	valid_placement = true
	
	visual_shape.visible = true
	outline.visible = true
	displayed = true

func hide_display():
	displayed = false
	last_displayed_position = Vector2.ONE * 1000000
	global_position = Vector2.ONE * 1000000
	valid_placement = true
	visual_shape.visible = false
	outline.visible = false
	update_transform()

func update_connection_group():
	connection_group = ConnectionGroup.new()
	for connector in connectors :
		var compatible_connector := connector.get_first_compatible_overlapping_connector()
		if compatible_connector : connection_group.members.append_array(compatible_connector.puzzle_piece.connection_group.members)
	
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
