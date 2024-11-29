extends Node2D
class_name SceneManager

@onready var camera = %Camera2D
@onready var scene_change_cooldown: Timer = $SceneChangeCooldown

var old_screen : Node2D
var current_screen : Node2D
var current_screen_resource : PackedScene
var default_resolution = Vector2(2560, 1440)
var direction = Vector2(-1, 0)
var transition_speed := 3.0

enum WORLDS {BASIC, ADVANCED, PORTAL, GRAVITY, ROTATING, PLATFORM, DIRT, KEY, FINAL, GRAVITY_KEY, DIRT_PORTAL, PLATFORM_ROTATING}
const CREDITS = preload("res://Scenes/Menus/Credits.tscn")
const MAIN_MENU = preload("res://Scenes/Menus/MainMenu.tscn")
const WORLD_SELECT = preload("res://Scenes/Menus/WorldSelect.tscn")
const LEVEL_SELECT_BASIC = preload("res://Scenes/Menus/Levels/level_select_basic.tscn")
const LEVEL_SELECT_PORTAL = preload("res://Scenes/Menus/Levels/level_select_portal.tscn")

func load_level_select(world : WORLDS, new_direction := Vector2(-1,0)) -> Node2D:
	match world :
		WORLDS.BASIC:
			return load_scene(LEVEL_SELECT_BASIC, new_direction)
		WORLDS.PORTAL:
			return load_scene(LEVEL_SELECT_PORTAL, new_direction)
		_:
			return null
			
func load_main_menu(new_direction := Vector2(1, 0)) -> Node2D:
	return load_scene(MAIN_MENU, new_direction)

func load_world_select_menu(new_direction := Vector2(1, 0), target_world_group := WorldSelectTree.TARGET_GROUPS.BASIC) -> Node2D:
	var menu = load_scene(WORLD_SELECT, new_direction)
	if menu:
		var tree = menu.get_node("Tree")
		tree.set_target_group(target_world_group)
		tree.finish_transition_instantly()
		return menu
	return null

func load_credits_menu(new_direction := Vector2(1, 0)) -> Node2D:
	return load_scene(CREDITS, new_direction)

func load_scene(scene_resource : Resource, new_direction := Vector2(1, 0), transition_speed := transition_speed) -> Node2D:
	if !scene_change_cooldown.is_stopped() : return null
	scene_change_cooldown.start()
	if old_screen != null: 
		old_screen.queue_free()
		old_screen = null
	self.transition_speed = transition_speed
	var scene = scene_resource.instantiate()
	var new_cam: Camera2D = scene.get_node("Camera2D")
	camera.target_position = new_cam.global_position
	camera.target_zoom = new_cam.zoom
	scene.remove_child(new_cam)
	
	# Set the starting position of the new screen based on direction
	scene.global_position = new_direction * camera.target_zoom * default_resolution
	
	old_screen = current_screen
	current_screen = scene
	current_screen_resource = scene_resource
	
	direction = new_direction  # Update the global direction
	
	add_child(scene)
	return scene

func reset_scene(direction := Vector2(0, -1)):
	load_scene(current_screen_resource , direction)
	Player.has_collectible = false
	
func _process(delta):
	if current_screen:
		# Target position for the new screen
		var target_position = Vector2(0, 0)
		var speed = maxf((current_screen.global_position - target_position).length() * transition_speed, 0) * delta
		current_screen.global_position = current_screen.global_position.move_toward(target_position, speed)
	
	if old_screen:
		# Target position for the old screen (opposite of the direction)
		var target_position = -direction * camera.target_zoom * default_resolution
		var speed = maxf((old_screen.global_position - target_position).length() * transition_speed, 0) * delta
		old_screen.global_position = old_screen.global_position.move_toward(target_position, speed)
		
		if (old_screen.global_position - target_position).length() < 100:
			old_screen.queue_free()
			old_screen = null
