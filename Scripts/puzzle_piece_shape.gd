@tool
extends Polygon2D
class_name PuzzlePieceShape

@onready var right_connector : PuzzlePieceConnector = $Connectors/RightConnector	
@onready var left_connector : PuzzlePieceConnector = $Connectors/LeftConnector
@onready var top_connector : PuzzlePieceConnector = $Connectors/TopConnector
@onready var bottom_connector : PuzzlePieceConnector = $Connectors/BottomConnector
@onready var left_collider = $"../Colliders/LeftCollider"
@onready var right_collider = $"../Colliders/RightCollider"
@onready var top_collider = $"../Colliders/TopCollider"
@onready var bottom_collider = $"../Colliders/BottomCollider"

	
var shape_size := 256

@export var connector_radius := 35.0 :
	set(value):
		connector_radius = value
		update_shape()
		
@export var connector_segments := 16 :
	set(value):
		connector_segments = value
		update_shape()

@export var regenerate := false : #This variable is meant for editor use only
	set(value):
		if value :
			update_shape()

# Helper function to create an arc of points
func create_arc(center: Vector2, start_angle: float, end_angle: float, segments := connector_segments) -> Array:
	var arc_points = []
	for i in range(segments + 1):
		var angle = lerp(float(start_angle), float(end_angle), float(i) / float(segments))
		arc_points.append(center + Vector2(cos(angle), sin(angle)) * connector_radius)
	return arc_points

func update_shape():
	var half_size = shape_size / 2.0
	var points = []
	points.append(Vector2(-half_size, -half_size))
	
	# Top Connector
	if top_connector.shape == PuzzlePieceConnector.ConnectorShape.SEMI_CIRCLE:
		if top_connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
			points += create_arc(Vector2(0, -half_size), PI, 2 * PI)
		elif top_connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
			points += create_arc(Vector2(0, -half_size), PI, 0)
	elif top_connector.shape == PuzzlePieceConnector.ConnectorShape.TRIANGLE:
		if top_connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
			points += create_arc(Vector2(0, -half_size), PI, 2 * PI, 2)
		elif top_connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
			points += create_arc(Vector2(0, -half_size), PI, 0, 2)
	points.append(Vector2(half_size, -half_size))

	# Right Connector
	if right_connector.shape == PuzzlePieceConnector.ConnectorShape.SEMI_CIRCLE:
		if right_connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
			points += create_arc(Vector2(half_size, 0), -PI / 2, PI / 2)
		elif right_connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
			points += create_arc(Vector2(half_size, 0), -PI / 2, -3 * PI / 2)
	elif right_connector.shape == PuzzlePieceConnector.ConnectorShape.TRIANGLE:
		if right_connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
			points += create_arc(Vector2(half_size, 0), -PI / 2, PI / 2, 2)
		elif right_connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
			points += create_arc(Vector2(half_size, 0), -PI / 2, -3 * PI / 2, 2)
	points.append(Vector2(half_size, half_size))

	# Bottom Connector
	if bottom_connector.shape == PuzzlePieceConnector.ConnectorShape.SEMI_CIRCLE:
		if bottom_connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
			points += create_arc(Vector2(0, half_size), 0, PI)
		elif bottom_connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
			points += create_arc(Vector2(0, half_size), 0, -PI)
	elif bottom_connector.shape == PuzzlePieceConnector.ConnectorShape.TRIANGLE:
		if bottom_connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
			points += create_arc(Vector2(0, half_size), 0, PI, 2)
		elif bottom_connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
			points += create_arc(Vector2(0, half_size), 0, -PI, 2)
	points.append(Vector2(-half_size, half_size))

	# Left Connector
	if left_connector.shape == PuzzlePieceConnector.ConnectorShape.SEMI_CIRCLE:
		if left_connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
			points += create_arc(Vector2(-half_size, 0), PI / 2, 3 * PI / 2)
		elif left_connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
			points += create_arc(Vector2(-half_size, 0), PI / 2, -PI / 2)
	elif left_connector.shape == PuzzlePieceConnector.ConnectorShape.TRIANGLE:
		if left_connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
			points += create_arc(Vector2(-half_size, 0), PI / 2, 3 * PI / 2, 2)
		elif left_connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
			points += create_arc(Vector2(-half_size, 0), PI / 2, -PI / 2, 2)
	points.append(Vector2(-half_size, -half_size))

	
	polygon = points
	
	right_connector.update_shape(connector_radius)
	left_connector.update_shape(connector_radius)
	top_connector.update_shape(connector_radius)
	bottom_connector.update_shape(connector_radius)
	
	var collider_shape = SegmentShape2D.new()
	collider_shape.a = Vector2(0, -half_size)
	collider_shape.b = Vector2(0, half_size)
	
	$"../Outline".regenerate(polygon)
