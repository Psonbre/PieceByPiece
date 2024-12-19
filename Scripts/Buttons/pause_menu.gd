extends Control
class_name PauseMenu

@export var hiddenPosition : Vector2
@export var showPosition : Vector2
@export var animationDuration : float = 1
@onready var drop_down_menu: BoxContainer = $Container/DropdownSection/DropDownMenu
@onready var level: Level = $"../.."
@onready var drop_down_button: TextureButton = $Container/DropDownButton
@onready var container = $Container
@onready var blur: ColorRect = $Blur

var is_opened := false
var container_tween : Tween
func _ready():
	drop_down_menu.position = hiddenPosition

func set_is_menu_opened(open):
	is_opened = open
	if is_opened : 
		blur.visible = true
		blur.create_tween().tween_method(func (bluriness) : blur.material.set_shader_parameter("amount", bluriness), blur.material.get_shader_parameter("amount"), 2.0, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		drop_down_menu.create_tween().tween_property(drop_down_menu, "position", showPosition, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		drop_down_button.create_tween().parallel().tween_property(drop_down_button, "rotation_degrees", 270, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	else : 
		blur.visible = false
		blur.create_tween().tween_method(func (bluriness) : blur.material.set_shader_parameter("amount", bluriness), blur.material.get_shader_parameter("amount"), 0.0, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		drop_down_menu.create_tween().tween_property(drop_down_menu, "position", hiddenPosition, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		drop_down_button.create_tween().parallel().tween_property(drop_down_button, "rotation_degrees", 0, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		if container_tween : container_tween.kill()
		
func _on_quit_button_pressed() -> void:
	SubSystemManager.get_scene_manager().load_level_select(level.world ,Vector2(-1,0))
	drop_down_button.button_pressed = false

func _on_restart_button_pressed() -> void:
	SubSystemManager.get_scene_manager().reset_scene()
	drop_down_button.button_pressed = false

func _on_settings_button_pressed() -> void:
	SubSystemManager.get_scene_manager().load_settings_menu(Vector2(0, -1), false)
	drop_down_button.button_pressed = false

func _on_drop_down_button_toggled(toggled_on: bool) -> void:
	set_is_menu_opened(toggled_on)
	is_opened = toggled_on
