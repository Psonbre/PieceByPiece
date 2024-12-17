extends FloatingUI
class_name LevelSelectButton

@onready var collectible_shape: PuzzlePieceShape = $"Level Button/Collectible/Shape"
@onready var collectible_outline: PuzzlePieceOutline = $"Level Button/Collectible/Outline"
@onready var overlay = $"Level Button/Overlay"
@onready var outline: PuzzlePieceOutline = $"Level Button/Outline"
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
	super._ready()
	default_scale = scale
	overlay.polygon = $"Level Button/Shape".polygon

func update_visuals():
	if requires and !requires.completed :
		visible = false
	overlay.self_modulate = Color(1,1,1,0)
	if collected_collectible :
		collectible_shape.color = Color.WHITE
		collectible_outline.default_color = Color.BLACK
		collectible_outline.texture = null

func _process(delta):
	super._process(delta)
	if mouse_hover :
		overlay.self_modulate = Color(1,1,1, move_toward(overlay.self_modulate.a, 0.1, delta / 2.0))
	else :
		overlay.self_modulate = Color(1,1,1,move_toward(overlay.self_modulate.a, 0, delta / 2.0))

func _on_focus_entered() -> void:
	outline.set_type(PuzzlePieceOutline.OutlineType.DRAGGING)
	create_tween().tween_property(self, "scale", default_scale * 1.07, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_focus_exited() -> void:
	outline.set_type(PuzzlePieceOutline.OutlineType.NORMAL)
	create_tween().tween_property(self, "scale", default_scale * 1.0, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_pressed() -> void:
	if level : 
		if SubSystemManager.get_scene_manager().load_level(find_parent("LevelSelect").world, level) :
			find_parent("LevelSelect").can_select_level = false
			SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
