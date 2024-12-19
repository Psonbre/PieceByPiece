extends Node

@export var hiddenPosition : Vector2
@export var showPosition : Vector2
@export var animationDuration : float = 1
@onready var drop_down_menu: VBoxContainer = $Container/DropdownSection/DropDownMenu
@onready var level: Level = $"../.."
var is_opened := false

func _ready():
	drop_down_menu.position = hiddenPosition
	
func set_is_menu_opened(open):
	is_opened = open
	if is_opened : create_tween().tween_property(drop_down_menu, "position", showPosition, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	else : create_tween().tween_property(drop_down_menu, "position", hiddenPosition, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func _on_drop_down_button_pressed() -> void:
	set_is_menu_opened(!is_opened)

func _on_quit_button_pressed() -> void:
	SubSystemManager.get_scene_manager().load_level_select(level.world ,Vector2(-1,0))

func _on_restart_button_pressed() -> void:
	SubSystemManager.get_scene_manager().reset_scene()

func _on_settings_button_pressed() -> void:
	SubSystemManager.get_scene_manager().load_settings_menu(Vector2(0, -1), false)
