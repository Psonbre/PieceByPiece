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
var discord_rpc
enum WORLDS {BASIC, ADVANCED, PORTAL, GRAVITY, ROTATING, PLATFORM, DIRT, KEY, FINAL, GRAVITY_KEY, DIRT_PORTAL, PLATFORM_ROTATING, DEMO}

const WORLDS_LEVEL_SELECT_SCENES = {
	WORLDS.BASIC: preload("res://Scenes/Menus/Levels/level_select_basic.tscn"),
	WORLDS.ADVANCED: preload("res://Scenes/Menus/Levels/level_select_advanced.tscn"),
	WORLDS.PORTAL: preload("res://Scenes/Menus/Levels/level_select_portal.tscn"),
	WORLDS.GRAVITY: preload("res://Scenes/Menus/Levels/level_select_gravity.tscn"),
	WORLDS.ROTATING: preload("res://Scenes/Menus/Levels/level_select_rotating.tscn"),
	WORLDS.PLATFORM: preload("res://Scenes/Menus/Levels/level_select_platform.tscn"),
	WORLDS.DIRT: preload("res://Scenes/Menus/Levels/level_select_dirt.tscn"),
	WORLDS.KEY: preload("res://Scenes/Menus/Levels/level_select_key.tscn"),
	WORLDS.FINAL: preload("res://Scenes/Menus/Levels/level_select_final.tscn"),
	WORLDS.GRAVITY_KEY: preload("res://Scenes/Menus/Levels/level_select_gravity-key.tscn"),
	WORLDS.DIRT_PORTAL: preload("res://Scenes/Menus/Levels/level_select_dirt-portal.tscn"),
	WORLDS.PLATFORM_ROTATING: preload("res://Scenes/Menus/Levels/level_select_platform-rotating.tscn"),
	WORLDS.DEMO : preload("res://Scenes/Menus/Levels/level_select_demo.tscn")
}
const WORLDS_DISCORD_PRESENCE = {
	WORLDS.BASIC: "Completing the King's Quest",
	WORLDS.ADVANCED: "Having Lumber Party",
	WORLDS.PORTAL: "Going on an Alien Adventure",
	WORLDS.GRAVITY: "Gravity",
	WORLDS.ROTATING: "Rotating",
	WORLDS.PLATFORM: "Platform",
	WORLDS.DIRT: "Mining Session",
	WORLDS.KEY: "Key",
	WORLDS.FINAL: "Final",
	WORLDS.GRAVITY_KEY: "Gravity Key",
	WORLDS.DIRT_PORTAL: "Dirt Portal",
	WORLDS.PLATFORM_ROTATING: "Platform Rotating",
	WORLDS.DEMO : "Trying out the Demo !"
}

const CREDITS = preload("res://Scenes/Menus/Credits.tscn")
const MAIN_MENU = preload("res://Scenes/Menus/MainMenu.tscn")
#const WORLD_SELECT = preload("res://Scenes/Menus/WorldSelect.tscn")
const WORLD_SELECT = preload("res://Scenes/Menus/WorldSelectDemo.tscn")

func load_level_select(world: WORLDS, new_direction := Vector2(-1, 0)) -> Node2D:
	var scene = load_scene(WORLDS_LEVEL_SELECT_SCENES[world], new_direction)
	if scene : updated_discord_presence(WORLDS_DISCORD_PRESENCE[world], "Choosing a level")
	return scene
	
func load_main_menu(new_direction := Vector2(1, 0)) -> Node2D:
	var main_menu = load_scene(MAIN_MENU, new_direction)
	if main_menu : updated_discord_presence("Staring at the main menu", "")
	return main_menu

func load_world_select_menu(new_direction := Vector2(1, 0), target_world_group = null) -> Node2D:
	var menu = load_scene(WORLD_SELECT, new_direction)
	if menu:
		var tree = menu.get_node("Tree")
		if target_world_group != null : tree.set_target_group(target_world_group)
		tree.finish_transition_instantly()
		updated_discord_presence("Selecting a world", "")
	return menu

func load_credits_menu(new_direction := Vector2(1, 0)) -> Node2D:
	var credits = load_scene(CREDITS, new_direction)
	if credits : updated_discord_presence("Looking at the credits", "")
	return credits

func load_level(world : WORLDS, scene_resource : Resource, new_direction := Vector2(1, 0)):
	var level = load_scene(scene_resource, new_direction)
	var regex = RegEx.new()
	regex.compile(r"\d+")
	if level : updated_discord_presence(WORLDS_DISCORD_PRESENCE[world], level.name)
	return level

func load_scene(scene_resource : Resource, new_direction := Vector2(1, 0), speed := transition_speed) -> Node2D:
	if !scene_change_cooldown.is_stopped() : return null
	scene_change_cooldown.start()
	if old_screen != null: 
		old_screen.queue_free()
		old_screen = null
	transition_speed = speed
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
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/transition.wav"), 0, transition_speed / 6.0 + (randf() - 0.5) / 4.0)
	return scene

func reset_scene(reset_direction := Vector2(0, -1)):
	load_scene(current_screen_resource , reset_direction)
	Player.has_collectible = false
	
func _process(delta):
	if discord_rpc : discord_rpc.run_callbacks()
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

func _ready() -> void:
	if OS.has_feature("discord_rpc") || OS.has_feature("editor") :
		discord_rpc = Engine.get_singleton("DiscordRPC")
		discord_rpc.app_id = 1315378919494385725
		discord_rpc.start_timestamp = int(Time.get_unix_time_from_system())
		discord_rpc.refresh()
	else :
		print("discord rich presence is disabled")

func updated_discord_presence(main : String, state := ""):
	if OS.get_name() in ["Windows", "Linux", "macOS"]:
		if !discord_rpc or !discord_rpc.get_is_discord_working() : return
		discord_rpc.details = main
		discord_rpc.state = state
		discord_rpc.refresh()
	
