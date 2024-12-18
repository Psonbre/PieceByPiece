extends Node2D
@onready var tree := $TreeContainer/Tree

var can_exit := true

func _ready() -> void:
	if get_tree().current_scene == self :
		SubSystemManager.get_scene_manager().load_world_select_menu.call_deferred(Vector2.ZERO)
		queue_free()

func _input(_event):
	var scene_manager = SubSystemManager.get_scene_manager()
	if Input.is_action_just_pressed("ui_cancel") and can_exit and scene_manager.old_screen != self:
		if scene_manager.load_main_menu(Vector2(0,-1)) : can_exit = false
