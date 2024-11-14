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

func add_connector_points(connector, base_point, start_angle, end_angle):
	if connector.shape == PuzzlePieceConnector.ConnectorShape.FLAT : return []
	var segments = 16 
	if connector.shape == PuzzlePieceConnector.ConnectorShape.TRIANGLE :
		segments = 2
	if connector.shape == PuzzlePieceConnector.ConnectorShape.SQUARE :
		segments = 3
	if connector.type == PuzzlePieceConnector.ConnectorType.BUMP:
		return create_arc(base_point, start_angle, end_angle, segments)
	elif connector.type == PuzzlePieceConnector.ConnectorType.HOLE:
		return create_arc(base_point, start_angle, start_angle - (end_angle - start_angle), segments)
	return []

func update_shape():
	var half_size = shape_size / 2.0
	var points = []
	points.append(Vector2(-half_size, -half_size))

	# Top Connector
	points += add_connector_points(top_connector, Vector2(0, -half_size), PI, 2 * PI)
	points.append(Vector2(half_size, -half_size))

	# Right Connector
	points += add_connector_points(right_connector, Vector2(half_size, 0), -PI / 2, PI / 2)
	points.append(Vector2(half_size, half_size))

	# Bottom Connector
	points += add_connector_points(bottom_connector, Vector2(0, half_size), 0, PI)
	points.append(Vector2(-half_size, half_size))

	# Left Connector
	points += add_connector_points(left_connector, Vector2(-half_size, 0), PI / 2, 3 * PI / 2)
	points.append(Vector2(-half_size, -half_size))

	# Generate the polygon and update connectors
	polygon = points
	right_connector.update_shape(connector_radius)
	left_connector.update_shape(connector_radius)
	top_connector.update_shape(connector_radius)
	bottom_connector.update_shape(connector_radius)

	# Update the collider shape
	var collider_shape = SegmentShape2D.new()
	collider_shape.a = Vector2(0, -half_size)
	collider_shape.b = Vector2(0, half_size)

	# Update the outline
	$"../Outline".regenerate(polygon)
