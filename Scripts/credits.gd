extends Node2D
var can_exit := true

func _ready() -> void:
	if get_tree().current_scene == self :
		SubSystemManager.get_scene_manager().load_credits_menu.call_deferred(Vector2.ZERO)
		queue_free()

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel") :
		if can_exit and SubSystemManager.get_scene_manager().load_main_menu(Vector2(-1,0)) :
			can_exit = false
