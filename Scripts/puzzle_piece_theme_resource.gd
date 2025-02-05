extends Resource
class_name PuzzlePieceTheme

@export var player_sprite := preload("res://Scenes/PlayerSprites/King.tscn")
@export var tileset_id := 3
@export var door_texture := preload("res://Assets/Sprites/Medieval/Door/medieval_door_CanvasTexture.tres")
@export var modulate := Color.WHITE
@export_flags_2d_render var light_layer
@export var collectable_light_energy := 1.5
