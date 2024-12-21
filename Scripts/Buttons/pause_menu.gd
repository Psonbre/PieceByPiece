extends Control
class_name PauseMenu

@export var hiddenPosition := Vector2(-75, 0.5)
@export var showPosition := Vector2(-6.5, 0.5)
@export var animationDuration : float = 1
@onready var drop_down_menu: BoxContainer = $SuperContainer/Container/DropdownSection/DropDownMenu
@onready var level: Level = $"../.."
@onready var drop_down_button: TextureButton = $SuperContainer/Container/Control/DropDownButton
@onready var container: Control = $SuperContainer/Container
@onready var blur: ColorRect = $Blur
@onready var super_container: GamepadUI = $SuperContainer

var is_opened := false
var current_tween : Tween
func _ready():
	drop_down_menu.position = hiddenPosition

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Pause"):
		if level != SubSystemManager.get_scene_manager().current_screen || SubSystemManager.get_scene_manager().old_screen: return
		drop_down_button.button_pressed = !drop_down_button.button_pressed
	elif Input.is_action_just_pressed("ui_cancel") :
		if level != SubSystemManager.get_scene_manager().current_screen || SubSystemManager.get_scene_manager().old_screen: return
		drop_down_button.button_pressed = false
	if !event is InputEventMouse : 
		if !is_opened:
			drop_down_button.set_focus_mode.call_deferred(Control.FOCUS_NONE)
		else :
			drop_down_button.set_focus_mode.call_deferred(Control.FOCUS_ALL)
			
func set_is_menu_opened(open):
	is_opened = open
	PauseManager.set_paused(open)
	#get_tree().paused = open
	if is_opened : 
		if current_tween : current_tween.kill()
		blur.visible = true
		current_tween = create_tween()
		current_tween.tween_method(func (bluriness) : blur.material.set_shader_parameter("amount", bluriness), blur.material.get_shader_parameter("amount"), 2.5, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		current_tween.parallel().tween_property(drop_down_menu, "position", showPosition, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		current_tween.parallel().tween_property(drop_down_button, "rotation_degrees", 270, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		current_tween.parallel().tween_property(super_container, "global_position", Vector2.ZERO, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		current_tween.parallel().tween_property(super_container, "scale", Vector2.ONE * 3, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	else : 
		if current_tween : current_tween.kill()
		current_tween = create_tween()
		current_tween.tween_method(func (bluriness) : blur.material.set_shader_parameter("amount", bluriness), blur.material.get_shader_parameter("amount"), 0.0, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		current_tween.parallel().tween_property(drop_down_menu, "position", hiddenPosition, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		current_tween.parallel().tween_property(drop_down_button, "rotation_degrees", 0, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT).finished.connect(func() : blur.visible = false)
		current_tween.parallel().tween_property(super_container, "position", Vector2.ZERO, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		current_tween.parallel().tween_property(super_container, "scale", Vector2.ONE * 1, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		
func _on_quit_button_pressed() -> void:
	if level != SubSystemManager.get_scene_manager().current_screen || SubSystemManager.get_scene_manager().old_screen: return
	if !is_opened : return
	drop_down_button.button_pressed = false
	SubSystemManager.get_scene_manager().load_level_select(level.world ,Vector2(-1,0))

func _on_restart_button_pressed() -> void:
	if level != SubSystemManager.get_scene_manager().current_screen || SubSystemManager.get_scene_manager().old_screen: return
	if !is_opened : return
	drop_down_button.button_pressed = false
	SubSystemManager.get_scene_manager().reset_scene()

func _on_settings_button_pressed() -> void:
	if level != SubSystemManager.get_scene_manager().current_screen || SubSystemManager.get_scene_manager().old_screen: return
	if !is_opened : return
	drop_down_button.button_pressed = false
	SubSystemManager.get_scene_manager().load_settings_menu(Vector2(0, -1), false)

func _on_drop_down_button_toggled(toggled_on: bool) -> void:
	if level != SubSystemManager.get_scene_manager().current_screen || SubSystemManager.get_scene_manager().old_screen: 
		drop_down_button.set_pressed_no_signal(false)
		return
	set_is_menu_opened(toggled_on)
	is_opened = toggled_on
	PauseManager.set_paused(is_opened)
	if is_opened : 
		super_container.IsMouseControlled = true
		drop_down_button.focus_mode = Control.FOCUS_ALL
		drop_down_button.grab_focus()
	else : 
		get_viewport().gui_release_focus()
		drop_down_button.focus_mode = Control.FOCUS_NONE
