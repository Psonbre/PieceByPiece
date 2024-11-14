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
	
func display(piece : PuzzlePiece, actual_global_position : Vector2, actual_global_rotation : float, visual_global_position : Vector2, visual_global_rotation : float):
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
	global_rotation = actual_global_rotation
	visual_shape.global_position = visual_global_position
	visual_shape.global_rotation = visual_global_rotation
	outline.position = visual_shape.position
	outline.rotation = visual_shape.rotation
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	update_connection_group()
	
	if all_overlapping_pieces_have_compatible_overlapping_connectors() && all_connectors_can_be_dropped():
		outline.material.set_shader_parameter('color', Vector4(1,1,1,0.5))
		valid_placement = true
	else :
		outline.material.set_shader_parameter('color', Vector4(1,0,0,0.5))
		valid_placement = false
	
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

func update_connection_group():
	var tested_pieces : Array[PuzzlePiece] = []
	connection_group = ConnectionGroup.new()
	
	var left_compatible = left_connector.get_first_compatible_overlapping_connector()
	var right_compatible = right_connector.get_first_compatible_overlapping_connector()
	var top_compatible = top_connector.get_first_compatible_overlapping_connector()
	var bottom_compatible = bottom_connector.get_first_compatible_overlapping_connector()
	if left_compatible : connection_group.add_member(left_compatible.puzzle_piece)
	if right_compatible : connection_group.add_member(right_compatible.puzzle_piece)
	if top_compatible : connection_group.add_member(top_compatible.puzzle_piece)
	if bottom_compatible : connection_group.add_member(bottom_compatible.puzzle_piece)

	while tested_pieces != connection_group.members :
		for piece in connection_group.members :
			if piece not in tested_pieces :
				add_piece_connections_to_connection_group(connection_group, piece)
				tested_pieces.append(piece)

func add_piece_connections_to_connection_group(cg: ConnectionGroup, piece: PuzzlePiece):
	if piece.left_connector.connected_to:
		cg.add_member(piece.left_connector.connected_to.puzzle_piece)
	if piece.right_connector.connected_to:
		cg.add_member(piece.right_connector.connected_to.puzzle_piece)
	if piece.top_connector.connected_to:
		cg.add_member(piece.top_connector.connected_to.puzzle_piece)
	if piece.bottom_connector.connected_to:
		cg.add_member(piece.bottom_connector.connected_to.puzzle_piece)
		
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
