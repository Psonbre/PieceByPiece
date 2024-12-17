extends Node2D

func _ready() -> void:
	if get_tree().current_scene == self :
		SubSystemManager.get_scene_manager().load_main_menu.call_deferred(Vector2.ZERO)
		queue_free()
