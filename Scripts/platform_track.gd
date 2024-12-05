extends Line2D
class_name Track
var puzzle_piece : PuzzlePiece :
	get():
		return get_parent().puzzle_piece
func get_closest_end(global_point : Vector2) -> Vector2 :
	var start = to_global(points[0])
	var end = to_global(points[points.size()-1])
	if start.distance_squared_to(global_point) < end.distance_squared_to(global_point) :
		return start
	else :
		return end
