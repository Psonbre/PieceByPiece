@tool
extends Line2D
class_name PuzzlePieceOutline

enum OutlineType {HIDDEN, NORMAL, DRAGGING, ERROR, PORTAL}

@export var outline_type := OutlineType.NORMAL :
	set(value):
		if value != outline_type :
			outline_type = value
			set_type(value)
			
@export var moving_outline_texture : Texture
@export var default_width := 5.0
@export var moving_width := 8.0

func set_type(type : OutlineType):
	outline_type = type
	material.set_shader_parameter('color', Vector4(1, 1, 1, 1))

	if type == OutlineType.HIDDEN:
		visible = false
	elif type == OutlineType.NORMAL:
		visible = true
		width = default_width
		texture = null
	elif type == OutlineType.DRAGGING:
		visible = true
		width = moving_width
		texture = moving_outline_texture
	elif type == OutlineType.ERROR:
		visible = true
		width = moving_width
		texture = moving_outline_texture
		material.set_shader_parameter('color', Vector4(1, 0, 0, 1))
	elif type == OutlineType.PORTAL:
		visible = true
		width = default_width
		texture = null

func regenerate(polygon):
	points = polygon
	if get_parent().has_node("Shadow") :
		$"../Shadow".z_index = -2
		$"../Shadow".points = points
	
func _ready():
	if not Engine.is_editor_hint():
		if material : material = material.duplicate()
