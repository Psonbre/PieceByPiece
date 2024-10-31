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

@export var hole_radius := 35.0 :
	set(value):
		hole_radius = value
		update_shape()
		
@export var hole_segments := 16 :
	set(value):
		hole_segments = value
		update_shape()
		
# Helper function to create an arc of points
func create_arc(center: Vector2, start_angle: float, end_angle: float) -> Array:
	var arc_points = []
	for i in range(hole_segments + 1):
		var angle = lerp(float(start_angle), float(end_angle), float(i) / float(hole_segments))
		arc_points.append(center + Vector2(cos(angle), sin(angle)) * hole_radius)
	return arc_points

func update_shape():
	var half_size = shape_size / 2.0
	var points = []
	# Start from top-left corner
	points.append(Vector2(-half_size, -half_size))
	
	# Top side (Flat, Bump, or Hole)
	if top_connector.type == PuzzlePieceConnector.ConnectorType.BUMP :
		points += create_arc(Vector2(0, -half_size), PI, 2 * PI)
	elif top_connector.type == PuzzlePieceConnector.ConnectorType.HOLE :
		points += create_arc(Vector2(0, -half_size), PI, 0)
	points.append(Vector2(half_size, -half_size))
	
	# Right side (Flat, Bump, or Hole)
	if right_connector.type == PuzzlePieceConnector.ConnectorType.BUMP :
		points += create_arc(Vector2(half_size, 0), -PI / 2, PI / 2)
	elif right_connector.type == PuzzlePieceConnector.ConnectorType.HOLE :
		points += create_arc(Vector2(half_size, 0), -PI / 2, -3 * PI / 2)
	points.append(Vector2(half_size, half_size))
	
	# Bottom side (Flat, Bump, or Hole)
	if bottom_connector.type == PuzzlePieceConnector.ConnectorType.BUMP :
		points += create_arc(Vector2(0, half_size), 0, PI)
	elif bottom_connector.type == PuzzlePieceConnector.ConnectorType.HOLE :
		points += create_arc(Vector2(0, half_size), 0, -PI)
	points.append(Vector2(-half_size, half_size))
	
	# Left side (Flat, Bump, or Hole)
	if left_connector.type == PuzzlePieceConnector.ConnectorType.BUMP :
		points += create_arc(Vector2(-half_size, 0), PI / 2, 3 * PI / 2)
	elif left_connector.type == PuzzlePieceConnector.ConnectorType.HOLE :
		points += create_arc(Vector2(-half_size, 0), PI / 2, -PI / 2)
	points.append(Vector2(-half_size, -half_size))
	
	# Assign the points to the polygon property
	polygon = points
	
	right_connector.update_shape(hole_radius)
	left_connector.update_shape(hole_radius)
	top_connector.update_shape(hole_radius)
	bottom_connector.update_shape(hole_radius)
	
	var collider_shape = SegmentShape2D.new()
	collider_shape.a = Vector2(0, -half_size)
	collider_shape.b = Vector2(0, half_size)
	
	$"../Outline".regenerate(polygon)
