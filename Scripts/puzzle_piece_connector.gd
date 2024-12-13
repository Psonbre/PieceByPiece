@tool
extends PuzzlePieceVisualConnector
class_name PuzzlePieceConnector

@onready var puzzle_piece : PuzzlePiece = $"../../.."
@export var side_collider : StaticBody2D
var rift : Rift

var connected_to : PuzzlePieceConnector = null :
	set(value):
		side_collider.get_node("CollisionShape2D").disabled = value != null
		connected_to = value
			
func get_first_compatible_overlapping_connector(include_dragging_piece := false, allow_flat_sides := false) -> PuzzlePieceConnector:
	if !include_dragging_piece && puzzle_piece.is_dragging : return
	for connector in get_overlapping_areas():
		if connector is PuzzlePieceConnector and connector.puzzle_piece is not GhostPiece:
			if connector.puzzle_piece == puzzle_piece || (!include_dragging_piece && connector.puzzle_piece.is_dragging) || (connector.shape == ConnectorShape.FLAT && !allow_flat_sides):
				continue
			if is_connector_compatible(connector, false) :
				return connector
	return null

func can_be_dropped():
	var compatible_overlapping_pieces = get_all_pieces_with_compatible_overlapping_connectors()
	for area in get_overlapping_areas():
		if area is PuzzlePieceConnector :
			if area.puzzle_piece == puzzle_piece || (puzzle_piece.is_dragging && area.puzzle_piece is GhostPiece):
				continue
			if !is_connector_compatible(area) :
				return false
		if area is PuzzlePiece :
			if area == puzzle_piece || (puzzle_piece.is_dragging && area is GhostPiece):
				continue
			if area not in compatible_overlapping_pieces :
				return false
	return true

func get_all_pieces_with_compatible_overlapping_connectors() :
	var pieces_with_valid_overlapping_connectors = []
	
	for connector in get_overlapping_areas():
		if connector is PuzzlePieceConnector :
			if connector.puzzle_piece == puzzle_piece || connector.puzzle_piece is GhostPiece:
				continue
			if is_connector_compatible(connector) :
				pieces_with_valid_overlapping_connectors.append(connector.puzzle_piece)
	return pieces_with_valid_overlapping_connectors

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
		SubSystemManager.get_scene_manager().current_screen.add_child(rift)
		rift.connected_to = self
	elif other_connector == null and rift != null:
		rift.connected_to = null
		rift = null	
		
func has_connection() :
	return connected_to != null || type == ConnectorShape.FLAT
