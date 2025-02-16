@tool
extends PuzzlePieceVisualConnector
class_name PuzzlePieceConnector

@onready var puzzle_piece : PuzzlePiece = $"../../.."
@export var side_collider : StaticBody2D
@export var bevel_side : Polygon2D
@onready var shape_cast_2d: ShapeCast2D = $CollisionShape2D/ShapeCast2D

var rift : Rift
var connection_light : ConnectionLight

var connected_to : PuzzlePieceConnector = null :
	set(value):
		side_collider.get_node("CollisionShape2D").disabled = value != null
		bevel_side.visible = !value
		connected_to = value

func _ready() -> void:
	area_entered.connect(on_area_entered)
	area_exited.connect(on_area_exited)

func update_shape(hole_radius : float):
	super.update_shape(hole_radius)
	shape_cast_2d.shape = collision_shape.shape

func on_area_entered(other_area : Area2D):
	if !puzzle_piece.is_dragging : return
	puzzle_piece.update_can_drop_indicator()
	
	if other_area is PuzzlePieceConnector and is_connector_compatible(other_area) :
		display_ghost_piece(other_area)

func on_area_exited(other_area : Area2D):
	if !puzzle_piece.is_dragging : return
	puzzle_piece.update_can_drop_indicator()
	
	if other_area is PuzzlePieceConnector and is_connector_compatible(other_area) :
		if puzzle_piece.ghost_piece.global_position == other_area.get_adjacent_piece_position(false):
			puzzle_piece.ghost_piece.hide_display()

func display_ghost_piece(other_connector : PuzzlePieceConnector = null) :
	if !other_connector : other_connector = get_first_compatible_overlapping_connector()
	puzzle_piece.ghost_piece.display(
		puzzle_piece,
		other_connector.get_adjacent_piece_position(false),
		deg_to_rad(round(puzzle_piece.target_rotated_angle / 90.0) * 90),
		other_connector.get_adjacent_piece_position(true), 
		other_connector.puzzle_piece.tilt_angle + deg_to_rad(round(puzzle_piece.target_rotated_angle / 90.0) * 90)
	)
	
func get_first_compatible_overlapping_connector(include_dragging_piece := false, allow_flat_sides := false) -> PuzzlePieceConnector:
	if !include_dragging_piece && puzzle_piece.is_dragging : return
	for connector in get_overlapping_connectors():
		if connector.puzzle_piece is not GhostPiece:
			if connector.puzzle_piece == puzzle_piece || (!include_dragging_piece && connector.puzzle_piece.is_dragging) || (connector.shape == ConnectorShape.FLAT && !allow_flat_sides):
				continue
			if is_connector_compatible(connector, false) :
				return connector
	return null

func can_be_dropped():
	var compatible_overlapping_pieces = get_all_pieces_with_compatible_overlapping_connectors()
	
	for connector in get_overlapping_connectors():
		if connector.puzzle_piece == puzzle_piece || (puzzle_piece.is_dragging && connector.puzzle_piece is GhostPiece):
			continue
		if !is_connector_compatible(connector) :
			return false
			
	for piece in get_overlapping_puzzle_pieces():
		if piece is PuzzlePiece :
			if piece == puzzle_piece || (puzzle_piece.is_dragging && piece is GhostPiece):
				continue
			if piece not in compatible_overlapping_pieces :
				return false
	return true

func get_all_pieces_with_compatible_overlapping_connectors() :
	var pieces_with_valid_overlapping_connectors = []
	
	for connector in get_overlapping_connectors():
		if connector.puzzle_piece == puzzle_piece || connector.puzzle_piece is GhostPiece:
			continue
		if is_connector_compatible(connector) :
			pieces_with_valid_overlapping_connectors.append(connector.puzzle_piece)
			
	return pieces_with_valid_overlapping_connectors

func get_all_incompatible_overlapping_pieces() :
	var dedup_overlapping_pieces = []
	for piece in get_overlapping_puzzle_pieces() :
		if piece not in dedup_overlapping_pieces :
			dedup_overlapping_pieces.append(piece)
	var pieces_with_compatible_overlapping_connectors = get_all_pieces_with_compatible_overlapping_connectors()
	return dedup_overlapping_pieces.filter(func (p) : return p not in pieces_with_compatible_overlapping_connectors)

func get_rounded_rotation():
	var normalized_self_rotation = global_rotation_degrees
	if normalized_self_rotation < 0:
		normalized_self_rotation += 360 * ceil(abs(normalized_self_rotation) / 360.0)
	elif normalized_self_rotation >= 360:
		normalized_self_rotation -= 360 * floor(normalized_self_rotation / 360.0)	
	return round(normalized_self_rotation / 90.0) * 90
	
func is_connector_compatible(other_connector: PuzzlePieceConnector, require_same_connection_group := true) -> bool:
	var rounded_self_rotation = get_rounded_rotation()
	var rounded_other_rotation = other_connector.get_rounded_rotation()

	var angle_diff = abs(rounded_self_rotation - rounded_other_rotation)

	if angle_diff != 180:
		return false

	if require_same_connection_group and shape == ConnectorShape.FLAT and other_connector.shape == ConnectorShape.FLAT and !puzzle_piece.connection_group.equals(other_connector.puzzle_piece.connection_group):
		return false

	# Check if connector types are compatible (should sum to 0 if opposite)
	if type * shape + other_connector.type * other_connector.shape != 0:
		return false

	# Check if connectors are already connected or if this piece is a ghost
	if other_connector.connected_to != self and other_connector.connected_to != null and puzzle_piece is not GhostPiece:
		return false

	return true

func get_adjacent_piece_position(account_for_tilt : bool):	
	if account_for_tilt :
		return puzzle_piece.global_position + (global_position - puzzle_piece.global_position) * 2
	else :
		var rotated_connector_position = position.rotated(deg_to_rad(round(puzzle_piece.target_rotated_angle / 90.0) * 90))
		return puzzle_piece.global_position + rotated_connector_position * 2

func connect_with_closest():
	var other_connector = get_first_compatible_overlapping_connector(false, true)
	if other_connector and other_connector.puzzle_piece is GhostPiece : other_connector = null
	connected_to = other_connector
	
	if !rift and other_connector and other_connector.rift == null and puzzle_piece.theme != other_connector.puzzle_piece.theme:
		rift = preload("res://Scenes/PuzzlePieces/rift.tscn").instantiate()
		puzzle_piece.level.add_child(rift)
		rift.connected_to = self
	elif other_connector == null and rift != null:
		rift.connected_to = null
		rift = null	

	if !connection_light and other_connector and other_connector.connection_light == null :
		connection_light = preload("res://Scenes/PuzzlePieces/connection_light.tscn").instantiate()
		puzzle_piece.level.add_child(connection_light)
		connection_light.connected_to = self
	elif other_connector == null and connection_light != null:
		connection_light.connected_to = null
		connection_light = null	
		
func has_connection() :
	return connected_to != null || type == ConnectorShape.FLAT

func get_overlapping_puzzle_pieces():
	force_update_transform()
	shape_cast_2d.force_shapecast_update()
	var overlapping_areas := shape_cast_2d.collision_result.map(func(r) : return instance_from_id(r.collider_id)).filter(func(p) : return p is PuzzlePiece or p is PuzzlePieceConnector)
	var overlapping_puzzle_pieces := overlapping_areas.map(func (p) :
		if p is PuzzlePiece :
			return p
		else :
			return p.puzzle_piece)
	return overlapping_puzzle_pieces
	
func get_overlapping_connectors():
	force_update_transform()
	shape_cast_2d.force_shapecast_update()
	return shape_cast_2d.collision_result.map(func(r) : return instance_from_id(r.collider_id)).filter(func(p) : return p is PuzzlePieceConnector)
