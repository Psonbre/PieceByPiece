extends Line2D
@onready var puzzle_piece: PuzzlePiece = $".."

func _process(_delta: float) -> void:
	global_position = puzzle_piece.global_position + Vector2(4, 4)
