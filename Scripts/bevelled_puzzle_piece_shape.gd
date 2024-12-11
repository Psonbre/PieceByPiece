@tool
extends PuzzlePieceShape
@onready var bevel_left: Polygon2D = $"../BevelLeft"
@onready var bevel_top: Polygon2D = $"../BevelTop"
@onready var bevel_right: Polygon2D = $"../BevelRight"
@onready var bevel_bottom: Polygon2D = $"../BevelBottom"

# Adjustable width of the bevel strip
@export var bevel_width := 5.0 :
	set(value):
		bevel_width = value
		update_shape()
		
func _ready() -> void:
	bevel_width = 3.7

func update_shape():
	if !is_node_ready() : return
	super.update_shape()
	bevel_left.polygon = get_segment_polygon("left", bevel_width)
	bevel_top.polygon = get_segment_polygon("top", bevel_width)
	bevel_right.polygon = get_segment_polygon("right", bevel_width)
	bevel_bottom.polygon = get_segment_polygon("down", bevel_width)

func get_segment_polygon(direction: String, width: float) -> PackedVector2Array:
	var line_points = get_segment_points(direction)
	if line_points.size() < 2:
		# Not enough points to form a polygon, just return them as-is
		return line_points

	# Compute an approximate direction vector for the entire line segment.
	# For simplicity, use the first and last points.
	var start_point = line_points[0]
	var end_point = line_points[line_points.size() - 1]
	var dir_vec = (end_point - start_point).normalized()

	# Compute a perpendicular normal to the direction vector
	# A vector (dx, dy) perpendicular to dir_vec can be (−dy, dx) or (dy, −dx)
	var normal = Vector2(-dir_vec.y, dir_vec.x).normalized()

	# Offset all points inward (along +normal) by the width
	var inner_points = PackedVector2Array()
	var outer_points = PackedVector2Array()

	# Add diagonal adjustments for sharp corners
	var start_diagonal = start_point + normal * width + dir_vec * width
	var end_diagonal = end_point + normal * width - dir_vec * width

	# Build the polygon with adjusted start and end points
	inner_points.append_array(line_points)  # Keep the original line as the inner edge

	# Adjust outer points for bevel
	outer_points.append(start_diagonal)  # Start with diagonal at the first point
	for i in range(1, line_points.size() - 1):
		outer_points.append(line_points[i] + normal * width)  # Regular offset points
	outer_points.append(end_diagonal)  # End with diagonal at the last point

	# To form a proper polygon, the points should connect from outer to inner
	outer_points.reverse()

	# Combine inner and outer points to form a closed polygon strip
	var polygon_points = PackedVector2Array()
	polygon_points.append_array(inner_points)
	polygon_points.append_array(outer_points)

	return polygon_points
