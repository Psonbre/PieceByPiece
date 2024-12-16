extends Node2D
class_name LevelSelectButton

@onready var collectible_shape: PuzzlePieceShape = $Collectible/Shape
@onready var collectible_outline: PuzzlePieceOutline = $Collectible/Outline
@onready var overlay = $Overlay
@onready var level_select: LevelSelect
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

func _ready():
	level_select = find_parent("LevelSelect")
	default_scale = scale
	overlay.polygon = $Shape.polygon

func update_visuals():
	if requires and !requires.completed :
		visible = false
	overlay.self_modulate = Color(1,1,1,0)
	if collected_collectible :
		collectible_shape.color = Color.WHITE
		collectible_outline.default_color = Color.BLACK
		collectible_outline.texture = null

func _process(delta):
	if mouse_hover :
		overlay.self_modulate = Color(1,1,1, move_toward(overlay.self_modulate.a, 0.1, delta / 2.0))
	else :
		overlay.self_modulate = Color(1,1,1,move_toward(overlay.self_modulate.a, 0, delta / 2.0))
		

func _on_mouse_entered():
	$Outline.set_type(PuzzlePieceOutline.OutlineType.DRAGGING)
	mouse_hover = true
	create_tween().tween_property(self, "scale", default_scale * 1.07, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_mouse_exited():
	$Outline.set_type(PuzzlePieceOutline.OutlineType.NORMAL)
	mouse_hover = false
	create_tween().tween_property(self, "scale", default_scale * 1.0, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _input(event: InputEvent) -> void:
	if mouse_hover and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and level_select.can_select_level:
		if level : 
			if SubSystemManager.get_scene_manager().load_level(find_parent("LevelSelect").world, level) :
				level_select.can_select_level = false
				SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
