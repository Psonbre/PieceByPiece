extends Node2D
class_name LevelSelectButton

@onready var collectible_shape: PuzzlePieceShape = $Collectible/Shape
@onready var collectible_outline: PuzzlePieceOutline = $Collectible/Outline
@onready var overlay = $Overlay
@export var level : PackedScene
@export var completed := false
@export var collected_collectible := false :
	set(value) :
		collected_collectible = value
		if not collectible_shape : return
		if collected_collectible :
			collectible_shape.color = Color.WHITE
			collectible_outline.default_color = Color.BLACK
@export var requires : LevelSelectButton

var default_scale : Vector2
var mouse_hover := false
var target_scale : Vector2


func _ready():
	default_scale = scale
	target_scale = default_scale
	overlay.polygon = $Shape.polygon
	if requires and !requires.completed :
		visible = false
	overlay.self_modulate = Color(1,1,1,0)
	if collected_collectible :
		collectible_shape.color = Color.WHITE
		collectible_outline.default_color = Color.BLACK
		collectible_outline.texture = null
	
func _process(delta):
	scale = scale.move_toward(target_scale, abs((target_scale - scale).length()) * delta * 6.0)
	if mouse_hover :
		overlay.self_modulate = Color(1,1,1, move_toward(overlay.self_modulate.a, 0.1, delta / 2.0))
	else :
		overlay.self_modulate = Color(1,1,1,move_toward(overlay.self_modulate.a, 0, delta / 2.0))
		

func _on_mouse_entered():
	$Outline.set_type(PuzzlePieceOutline.OutlineType.DRAGGING)
	mouse_hover = true
	target_scale = default_scale * 1.1

func _on_mouse_exited():
	$Outline.set_type(PuzzlePieceOutline.OutlineType.NORMAL)
	mouse_hover = false
	target_scale = default_scale

func _input(event: InputEvent) -> void:
	if mouse_hover and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if level : SubSystemManager.get_scene_manager().load_scene(level)
