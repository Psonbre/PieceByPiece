@tool
class_name Door
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
const WIN_JINGLE = preload("res://Assets/Sounds/winJingle.ogg")
var puzzle_piece : PuzzlePiece

func _ready():
	if Engine.is_editor_hint() : return
	puzzle_piece = get_parent().get_parent()

func _on_body_entered(body):
	if body is Player && !puzzle_piece.is_dragging && SubSystemManager.get_scene_manager().old_screen == null:
		body.update_overlapping_pieces()
		if puzzle_piece.is_ancestor_of(body) : 
			SubSystemManager.get_sound_manager().play_sound(WIN_JINGLE, -8)
			body.win(self)

func set_texture(texture : Texture2D) :
	sprite_2d.texture = texture
