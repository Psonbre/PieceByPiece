@tool
extends Line2D
class_name PuzzlePieceOutline

enum OutlineType {HIDDEN, NORMAL, DRAGGING, ERROR, HIGHLIGHT}

@export var outline_type := OutlineType.NORMAL :
	set(value):
		if value != outline_type :
			outline_type = value
			set_type(value)
			
var moving_outline_texture := preload("res://Assets/Sprites/moving_outline_texture.png")
var normal_texture : Texture
@export var normal_width := 4.0
@export var highlight_width := 3.0
@export var dragging_width := 5.0

func _ready() -> void:
	closed = true
	if not Engine.is_editor_hint():
		if material : material = material.duplicate()
	await get_tree().get_frame()
	set_type(OutlineType.NORMAL)
		
func set_type(type : OutlineType):
	outline_type = type
	z_index = -1
	
	if type == OutlineType.HIDDEN:
		visible = false
	elif type == OutlineType.NORMAL:
		visible = true
		width = normal_width
		texture = normal_texture
		if material :
			material.set_shader_parameter('speed', 0)
			material.set_shader_parameter('color', Color.BLACK)
	elif type == OutlineType.DRAGGING:
		z_index = 1
		visible = true
		width = dragging_width
		texture = moving_outline_texture
		if material :
			material.set_shader_parameter('speed', 1.4)
			material.set_shader_parameter('color', Color.WHITE)
	elif type == OutlineType.HIGHLIGHT:
		z_index = 1
		visible = true
		width = dragging_width
		texture = moving_outline_texture
		if material :
			material.set_shader_parameter('speed', 1.4)
			material.set_shader_parameter('color', Color.WHITE)
		#visible = true
		#width = highlight_width
		#texture = normal_texture
		#material.set_shader_parameter('speed', 0)
		#material.set_shader_parameter('color', Color.WHITE)
	elif type == OutlineType.ERROR:
		z_index = 1
		visible = true
		width = dragging_width
		texture = moving_outline_texture
		if material :
			material.set_shader_parameter('speed', 1.4)
			material.set_shader_parameter('color', Color.RED)
		
func regenerate(polygon : PackedVector2Array):
	polygon.remove_at(polygon.size() - 1)
	points = polygon
	if get_parent().has_node("Shadow") :
		$"../Shadow".z_index = -2
		$"../Shadow".points = points
