@tool
extends Area2D
class_name PuzzlePieceConnector

enum Side {TOP = 1, LEFT = -2, RIGHT = 2, BOTTOM = -1}
enum ConnectorType {FLAT = 0, BUMP = 1, HOLE = -1}

@onready var puzzle_piece : PuzzlePiece = $"../../.."
@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var shape : PuzzlePieceShape = $"../.."

@export var type := ConnectorType.FLAT : 
	set(value) :
		type = value
		if (shape) : shape.update_shape()

@export var side := Side.LEFT
@export var side_collider : StaticBody2D

var connected_to : PuzzlePieceConnector = null :
	set(value):
		side_collider.get_node("CollisionShape2D").disabled = value != null
		connected_to = value
			
func get_compatible_overlapping_connector(include_dragging_piece : bool = false):
	if !include_dragging_piece && puzzle_piece.is_dragging : return
	for connector in get_overlapping_areas():
		if connector is PuzzlePieceConnector :
			if connector.puzzle_piece == puzzle_piece || (!include_dragging_piece && connector.puzzle_piece.is_dragging):
				continue
			if is_connector_compatible(connector) :
				return connector
	return null

func can_be_dropped():
	var compatible_overlapping_pieces = get_all_pieces_with_compatible_overlapping_connectors()
	for area in get_overlapping_areas():
		if area is PuzzlePieceConnector :
			if area.puzzle_piece == puzzle_piece :
				continue
			if !is_connector_compatible(area) :
				return false
		if area is PuzzlePiece :
			if area == puzzle_piece :
				continue
			if area not in compatible_overlapping_pieces :
				get_all_pieces_with_compatible_overlapping_connectors()
				return false
	return true

func get_all_pieces_with_compatible_overlapping_connectors() :
	var pieces_with_valid_overlapping_connectors = []
	
	for connector in get_overlapping_areas():
		if connector is PuzzlePieceConnector :
			if connector.puzzle_piece == puzzle_piece :
				continue
			if is_connector_compatible(connector) :
				pieces_with_valid_overlapping_connectors.append(connector.puzzle_piece)
	return pieces_with_valid_overlapping_connectors

func is_connector_compatible(other_connector : PuzzlePieceConnector):
	if side + other_connector.side != 0 : #incompatible sides
		return false
	if type + other_connector.type != 0 : #incompatible connectors
		return false
	if other_connector.connected_to != self and other_connector.connected_to != null and puzzle_piece is not GhostPiece:
		return false
	return true

func get_adjacent_piece_position(account_for_rotation : bool):	
	if account_for_rotation :
		return puzzle_piece.global_position + (global_position - puzzle_piece.global_position) * 2
	else :
		return puzzle_piece.global_position + position * 2

func update_shape(hole_radius : float):
	if type == ConnectorType.FLAT :
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = hole_radius * 1.0
		collision_shape.shape = circle_shape
		collision_shape.position = Vector2.ZERO
	elif type == ConnectorType.BUMP :
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = hole_radius * 1.0
		collision_shape.shape = circle_shape
		collision_shape.position = Vector2.ZERO
	elif type == ConnectorType.HOLE :
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = hole_radius * 1.0
		collision_shape.shape = circle_shape
		collision_shape.position = Vector2.ZERO
		#var rectangle_shape = RectangleShape2D.new()
		#rectangle_shape.size = Vector2(hole_radius, hole_radius*2)
		#collision_shape.shape = rectangle_shape
		#collision_shape.position = Vector2(-hole_radius/2,0)

func connect_with_closest():
	connected_to = get_compatible_overlapping_connector()
	
func has_connection() :
	return connected_to != null || type == ConnectorType.FLAT
