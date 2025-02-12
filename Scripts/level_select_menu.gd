extends	Node
class_name LevelSelect
@export var world : SceneManager.WORLDS
@export var world_select_tree_target_group := WorldSelectTree.TARGET_GROUPS.BASIC
@export var background_gradient : Gradient = preload("res://Assets/Gradients/rainbow_gradient.tres")
var can_exit := true
var can_select_level := true

func _input(_event):
	if Input.is_action_just_pressed("ui_cancel"):
		_quit()

func _ready() -> void:
	if get_tree().current_scene == self :
		SubSystemManager.get_scene_manager().load_level_select.call_deferred(world, Vector2.ZERO)
		queue_free()
		return
	var buttons = get_tree().get_nodes_in_group("LevelSelectButton")
	var completed_levels = SaveManager.get_completed_levels(world)
	var collectible_levels = SaveManager.get_collectible_levels(world)
	for button in buttons :
		button = button as LevelSelectButton
		if button.level : 
			button.completed = completed_levels.has(button.level.resource_path)
			button.collected_collectible = collectible_levels.has(button.level.resource_path)
		else : 
			button.completed = false
			button.collected_collectible = false
		
	for button in buttons :
		button.update_visuals()
	
func _quit():
	var scene_manager = SubSystemManager.get_scene_manager()
	if can_exit and scene_manager.old_screen != self:
		if scene_manager.load_world_select_menu(Vector2(0,-1), world_select_tree_target_group) : can_exit = false


func _on_back_pressed() -> void:
	_quit()
