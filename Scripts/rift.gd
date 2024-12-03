extends Line2D
class_name Rift
var target_resolution := 3.0
var connected_to : PuzzlePieceConnector :
	set(value):
		connected_to = value
		if connected_to :
			
			global_position = connected_to.puzzle_piece.global_position
			
			match connected_to.get_rounded_rotation():
				0.0 :
					points = connected_to.puzzle_piece.shape.get_segment_points("right")
				90.0:
					points = connected_to.puzzle_piece.shape.get_segment_points("down")
				180.0:
					points = connected_to.puzzle_piece.shape.get_segment_points("left")
				270.0:
					points = connected_to.puzzle_piece.shape.get_segment_points("top")
		else :
			queue_free()
