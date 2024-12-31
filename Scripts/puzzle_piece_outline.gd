@tool
extends Line2D
class_name PuzzlePieceOutline

enum OutlineType {HIDDEN, NORMAL, DRAGGING, ERROR, HIGHLIGHT}

var outline_type := OutlineType.NORMAL :
	set(value):
		if value != outline_type :
			outline_type = value
			set_type(value)

@export var hidden_outline : OutlineTypeResource
@export var normal_outline : OutlineTypeResource
@export var dragging_outline : OutlineTypeResource
@export var error_outline : OutlineTypeResource
@export var highlight_outline : OutlineTypeResource

func _ready() -> void:
	closed = true
	if not Engine.is_editor_hint():
		if material : material = material.duplicate()
	await get_tree().get_frame()
	set_type(OutlineType.NORMAL)
		
func set_type(type : OutlineType):
	outline_type = type
	if type == OutlineType.HIDDEN:
		apply_outline(hidden_outline)
	elif type == OutlineType.NORMAL:
		apply_outline(normal_outline)
	elif type == OutlineType.DRAGGING:
		apply_outline(dragging_outline)
	elif type == OutlineType.HIGHLIGHT:
		apply_outline(highlight_outline)
	elif type == OutlineType.ERROR:
		apply_outline(error_outline)


func apply_outline(outline : OutlineTypeResource) :
	if not outline : return
	z_index = outline.z_index
	visible = outline.visible
	width = outline.width
	texture = outline.texture
	material.set_shader_parameter('speed', outline.scrolling_speed)
	material.set_shader_parameter('color', outline.color)
	

func regenerate(polygon : PackedVector2Array):
	polygon.remove_at(polygon.size() - 1)
	points = polygon
	if get_parent().has_node("Shadow") :
		$"../Shadow".z_index = -2
		$"../Shadow".points = points
