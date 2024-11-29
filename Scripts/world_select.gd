extends Node2D
@onready var tree := $Tree

var can_exit := true
func _input(_event):
	var scene_manager = SubSystemManager.get_scene_manager()
	if Input.is_action_just_pressed("Pause") and can_exit and scene_manager.old_screen != self:
		can_exit = false
		tree.set_target_group(WorldSelectTree.TARGET_GROUPS.BASIC)
		scene_manager.load_main_menu(Vector2(0,-1))
