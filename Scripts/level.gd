extends Node2D
class_name Level	
		
func _ready() -> void:
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces"):
		piece.shape.update_shape()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Reset") :
		get_tree().reload_current_scene()
