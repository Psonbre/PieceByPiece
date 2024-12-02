extends	Node

@export var world : SceneManager.WORLDS
@export var world_select_tree_target_group := WorldSelectTree.TARGET_GROUPS.BASIC
var can_exit := true

func _input(_event):
	var scene_manager := SubSystemManager.get_scene_manager()
	if Input.is_action_just_pressed("Pause") and can_exit and scene_manager.old_screen != self:
		if scene_manager.load_world_select_menu(Vector2(-1,0), world_select_tree_target_group) : can_exit = false

func _ready() -> void:
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
	
