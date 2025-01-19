extends Resource
class_name PuzzlePieceTheme

@export var player_sprite := preload("res://Scenes/PlayerSprites/King.tscn")
@export var tileset_id := 3
@export var door_texture := preload("res://Assets/Sprites/Medieval/medieval_door.png")
@export var modulate := Color.WHITE
@export_flags_2d_render var illuminated_by
@export_flags_2d_render var illuminated_by_when_dragging
@export_flags_2d_render var illuminating
@export_flags_2d_render var illuminating_when_dragging
