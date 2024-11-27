class_name Door
extends Area2D

const WIN_JINGLE = preload("res://Assets/Sounds/winJingle.ogg")
var puzzle_piece : PuzzlePiece
func _ready():
	puzzle_piece = get_parent().get_parent()

func _on_body_entered(body):
	if body is Player && body.is_physics_processing() && !puzzle_piece.is_dragging && SubSystemManager.get_scene_manager().old_screen == null:
		SubSystemManager.get_sound_manager().play_sound(WIN_JINGLE, -5)
		body.win(self)
