@tool
extends Polygon2D
class_name PuzzlePieceShape

@onready var right_connector : PuzzlePieceConnector = $Connectors/RightConnector	
@onready var left_connector : PuzzlePieceConnector = $Connectors/LeftConnector
@onready var top_connector : PuzzlePieceConnector = $Connectors/TopConnector
@onready var bottom_connector : PuzzlePieceConnector = $Connectors/BottomConnector
		
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
	var points = []
	# Start from top-left corner
	points.append(Vector2(-128, -128))
	
	# Top side (Flat, Bump, or Hole)
	if top_connector.type == PuzzlePieceConnector.ConnectorType.BUMP :
		points += create_arc(Vector2(0, -128), PI, 2 * PI)
	elif top_connector.type == PuzzlePieceConnector.ConnectorType.HOLE :
		points += create_arc(Vector2(0, -128), PI, 0)
	points.append(Vector2(128, -128))
	
	# Right side (Flat, Bump, or Hole)
	if right_connector.type == PuzzlePieceConnector.ConnectorType.BUMP :
		points += create_arc(Vector2(128, 0), -PI / 2, PI / 2)
	elif right_connector.type == PuzzlePieceConnector.ConnectorType.HOLE :
		points += create_arc(Vector2(128, 0), -PI / 2, -3 * PI / 2)
	points.append(Vector2(128, 128))
	
	# Bottom side (Flat, Bump, or Hole)
	if bottom_connector.type == PuzzlePieceConnector.ConnectorType.BUMP :
		points += create_arc(Vector2(0, 128), 0, PI)
	elif bottom_connector.type == PuzzlePieceConnector.ConnectorType.HOLE :
		points += create_arc(Vector2(0, 128), 0, -PI)
	points.append(Vector2(-128, 128))
	
	# Left side (Flat, Bump, or Hole)
	if left_connector.type == PuzzlePieceConnector.ConnectorType.BUMP :
		points += create_arc(Vector2(-128, 0), PI / 2, 3 * PI / 2)
	elif left_connector.type == PuzzlePieceConnector.ConnectorType.HOLE :
		points += create_arc(Vector2(-128, 0), PI / 2, -PI / 2)
	points.append(Vector2(-128, -128))
	
	# Assign the points to the polygon property
	polygon = points
	right_connector.update_shape(hole_radius)
	left_connector.update_shape(hole_radius)
	top_connector.update_shape(hole_radius)
	bottom_connector.update_shape(hole_radius)
	$"../Outline".regenerate(polygon)
