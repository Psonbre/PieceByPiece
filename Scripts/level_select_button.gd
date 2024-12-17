extends FloatingUI
class_name LevelSelectButton

@onready var collectible_shape: PuzzlePieceShape = $"Level Button/Collectible/Shape"
@onready var collectible_outline: PuzzlePieceOutline = $"Level Button/Collectible/Outline"
@onready var overlay = $"Level Button/Overlay"
@onready var level_button: Area2D = $"Level Button"
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
	default_scale = level_button.scale
	overlay.polygon = $"Level Button/Shape".polygon

func set_start_position():
	start_position = level_button.position
	
func update_visuals():
	if requires and !requires.completed :
		visible = false
	overlay.self_modulate = Color(1,1,1,0)
	if collected_collectible :
		collectible_shape.color = Color.WHITE
		collectible_outline.default_color = Color.BLACK
		collectible_outline.texture = null

func _process(delta):
	level_button.position = start_position + Vector2(cos(Time.get_unix_time_from_system() * horizontal_speed + rand) * horizontal_intensity, sin(Time.get_unix_time_from_system() + rand * vertical_speed) * vertical_intensity)
	if mouse_hover :
		overlay.self_modulate = Color(1,1,1, move_toward(overlay.self_modulate.a, 0.1, delta / 2.0))
	else :
		overlay.self_modulate = Color(1,1,1,move_toward(overlay.self_modulate.a, 0, delta / 2.0))

func _on_focus_entered() -> void:
	outline.set_type(PuzzlePieceOutline.OutlineType.DRAGGING)
	level_button.create_tween().tween_property(level_button, "scale", default_scale * 1.07, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_focus_exited() -> void:
	outline.set_type(PuzzlePieceOutline.OutlineType.NORMAL)
	level_button.create_tween().tween_property(level_button, "scale", default_scale * 1.0, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_pressed() -> void:
	if level : 
		var level_select_menu = get_tree().get_first_node_in_group("LevelSelectMenu")
		if SubSystemManager.get_scene_manager().load_level(level_select_menu.world, level) :
			level_select_menu.can_select_level = false
			SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
