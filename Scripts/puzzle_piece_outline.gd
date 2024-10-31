@tool
extends Line2D
class_name PuzzlePieceOutline

enum OutlineType {HIDDEN, NORMAL, MOVING}

@export var outline_type := OutlineType.NORMAL :
	set(value):
		outline_type = value
		if outline_type == OutlineType.HIDDEN:
			visible = false
		elif outline_type == OutlineType.NORMAL:
			visible = true
			width = default_width
			texture = null
		elif outline_type == OutlineType.MOVING:
			visible = true
			width = moving_width
			texture = moving_outline_texture
@export var moving_outline_texture : Texture
@export var default_width := 5.0
@export var moving_width := 8.0

func regenerate(polygon):
	points = polygon
