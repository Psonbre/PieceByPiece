extends Node

@export var hiddenPosition : Vector2
@export var showPosition : Vector2
@export var animationDuration : float = 1
@onready var drop_down_menu: VBoxContainer = $Container/DropdownSection/DropDownMenu
var is_opened := false

func _ready():
	drop_down_menu.position = hiddenPosition
	
func set_is_menu_opened(open):
	is_opened = open
	if is_opened : create_tween().tween_property(drop_down_menu, "position", showPosition, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	else : create_tween().tween_property(drop_down_menu, "position", hiddenPosition, animationDuration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)


func _on_drop_down_button_pressed() -> void:
	set_is_menu_opened(!is_opened)
