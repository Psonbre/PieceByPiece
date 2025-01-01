@tool
extends Polygon2D
class_name PuzzlePieceShape

@onready var right_connector : PuzzlePieceVisualConnector = $Connectors/RightConnector	
@onready var left_connector : PuzzlePieceVisualConnector = $Connectors/LeftConnector
@onready var top_connector : PuzzlePieceVisualConnector = $Connectors/TopConnector
@onready var bottom_connector : PuzzlePieceVisualConnector = $Connectors/BottomConnector

var shape_size := 256
var puzzle_piece : PuzzlePiece : 
	get():
		return get_parent()
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

func add_connector_points(connector : PuzzlePieceVisualConnector, base_point, start_angle, end_angle):
	if connector.shape == PuzzlePieceConnector.ConnectorShape.FLAT : return []
	if connector is PuzzlePieceConnector and connector.connected_to != null : return []
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
	if !top_connector or !bottom_connector or !left_connector or !right_connector : return
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
	var outline := $"../Outline"
	outline.regenerate(polygon)

func get_segment_points(side: String) -> Array:
	var start_point: Vector2
	var end_point: Vector2

	match side:
		"left":
			start_point = Vector2(-shape_size / 2.0, shape_size / 2.0)  # Bottom-left
			end_point = Vector2(-shape_size / 2.0, -shape_size / 2.0)   # Top-left
		"right":
			start_point = Vector2(shape_size / 2.0, -shape_size / 2.0)  # Top-right
			end_point = Vector2(shape_size / 2.0, shape_size / 2.0)     # Bottom-right
		"top":
			start_point = Vector2(-shape_size / 2.0, -shape_size / 2.0) # Top-left
			end_point = Vector2(shape_size / 2.0, -shape_size / 2.0)    # Top-right
		"down":
			start_point = Vector2(shape_size / 2.0, shape_size / 2.0)   # Bottom-right
			end_point = Vector2(-shape_size / 2.0, shape_size / 2.0)    # Bottom-left
		_:
			print("Invalid side specified: ", side)
			return []

	# Collect points between the two delimiting corners
	var segment_points = []
	var collecting = false

	var cloned_polygon = polygon.duplicate()
	cloned_polygon.append(cloned_polygon[0])
	for point in cloned_polygon:
		# Start collecting once the start point is encountered
		if point == start_point:
			collecting = true

		if collecting:
			segment_points.append(point)
			if point == end_point:
				break

	return segment_points
