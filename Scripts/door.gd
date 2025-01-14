@tool
class_name Door
extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
const WIN_JINGLE = preload("res://Assets/Sounds/winJingle.ogg")
var puzzle_piece : PuzzlePiece

const THEME_TEXTURE_MAP = {
	PuzzlePiece.THEME.MEDIEVAL : preload("res://Assets/Sprites/Medieval/medieval_door.png"),
	PuzzlePiece.THEME.MINER : preload("res://Assets/Sprites/Miner/miner_door.png"),
}

func _ready():
	if Engine.is_editor_hint() : return
	puzzle_piece = get_parent().get_parent()

func _on_body_entered(body):
	if body is Player && body.is_physics_processing() && !puzzle_piece.is_dragging && SubSystemManager.get_scene_manager().old_screen == null:
		SubSystemManager.get_sound_manager().play_sound(WIN_JINGLE, -8)
		body.win(self)

func set_theme(theme : PuzzlePiece.THEME) :
	sprite_2d.texture = THEME_TEXTURE_MAP.get(theme, THEME_TEXTURE_MAP.get(PuzzlePiece.THEME.MEDIEVAL))
