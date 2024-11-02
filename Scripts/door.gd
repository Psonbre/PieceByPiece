class_name Door
extends Area2D

var puzzle_piece : PuzzlePiece

func _ready():
	puzzle_piece = get_parent().get_parent()

func _on_body_entered(body):
	if body is Player && body.is_physics_processing() && !puzzle_piece.is_dragging && get_tree().get_first_node_in_group("GameManager").old_screen == null:
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/winJingle.ogg", -5)
		body.win(self)
