extends	Node

@export var world : SceneManager.WORLDS

func _input(_event):
	if Input.is_action_just_pressed("Pause"):
		SubSystemManager.get_scene_manager().load_world_select_menu(Vector2(-1,0))

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
	
