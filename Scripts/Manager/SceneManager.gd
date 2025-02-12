extends Node2D
class_name SceneManager

@export var default_gradient : Gradient
@onready var camera = %Camera2D
@onready var scene_change_cooldown: Timer = $SceneChangeCooldown
var old_screen : Node2D
var current_screen : Node2D
var current_screen_resource : PackedScene
var default_resolution = Vector2(2560, 1440)
var direction = Vector2(-1, 0)
var transition_speed := 3.0
var previous_scene_zoom := Vector2.ONE
var previous_scene_camera_position := Vector2.ZERO
var previous_screen_resource : PackedScene
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
const SETTINGS = preload("res://Scenes/Menus/Settings.tscn")

func load_level_select(world: WORLDS, new_direction := Vector2(-1, 0)) -> Node2D:
	var scene = load_scene(WORLDS_LEVEL_SELECT_SCENES[world], new_direction)
	if scene : 
		updated_discord_presence(WORLDS_DISCORD_PRESENCE[world], "Choosing a level")
	return scene
	
func load_main_menu(new_direction := Vector2(1, 0)) -> Node2D:
	var main_menu = load_scene(MAIN_MENU, new_direction)
	if main_menu : 
		updated_discord_presence("Staring at the main menu", "")
	return main_menu

func load_world_select_menu(new_direction := Vector2(1, 0), target_world_group = null) -> Node2D:
	var menu = load_scene(WORLD_SELECT, new_direction)
	if menu: updated_discord_presence("Selecting a world", "")
	return menu

func load_credits_menu(new_direction := Vector2(1, 0)) -> Node2D:
	var credits = load_scene(CREDITS, new_direction)
	if credits : 
		updated_discord_presence("Looking at the credits", "")
	return credits
	
func load_settings_menu(new_direction := Vector2(1, 0), destroy_old_screen := true) -> Node2D:
	var settings = load_scene(SETTINGS, new_direction, destroy_old_screen)
	if settings : 
		updated_discord_presence("Modifying the settings", "")
		if !destroy_old_screen :
			settings.get_node("Settings/Back").exit_mode = 1
	return settings

func load_level(world : WORLDS, scene_resource : Resource, new_direction := Vector2(1, 0)):
	var level = load_scene(scene_resource, new_direction)
	if level : 
		PuzzlePiece.global_dragging = false
		updated_discord_presence(WORLDS_DISCORD_PRESENCE[world], level.name)
	return level
 
func load_scene(scene_resource : Resource, new_direction := Vector2(1, 0), destroy_old_screen := true, allow_same_scene := false, speed := transition_speed) -> Node2D:
	if !scene_change_cooldown.is_stopped() : return null
	if scene_resource == current_screen_resource and !allow_same_scene: return null
	scene_change_cooldown.start()
	if old_screen != null: 
		old_screen.queue_free()
		old_screen = null
	transition_speed = speed
	var scene = scene_resource.instantiate()
	
	# Set the starting position of the new screen based on direction
	var new_cam: Camera2D = scene.get_node("Camera2D")
	var target_camera_zoom := new_cam.zoom
	var target_camera_position := new_cam.global_position
	if new_direction != Vector2.ZERO:
		scene.global_position = new_direction * camera.target_zoom * default_resolution
	else :
		scene.global_position = Vector2.ZERO
		camera.global_position = target_camera_position
		camera.zoom = target_camera_zoom
	
	old_screen = current_screen
	current_screen = scene
	
	direction = new_direction  # Update the global direction
	
	add_child(scene)
	
	slide_screens(scene_resource, destroy_old_screen, target_camera_position, target_camera_zoom)
	scene.remove_child(new_cam)
	
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/transition.wav"), 0, transition_speed / 6.0 + (randf() - 0.5) / 4.0)
	
	return scene

func slide_screens(new_screen_resource : PackedScene, destroy_old_screen := true, camera_position := Vector2.ZERO, camera_zoom := Vector2.ONE):
	camera.pan(camera_position, camera_zoom)
	current_screen.create_tween().tween_property(current_screen, "global_position", Vector2.ZERO, 2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	if old_screen :
		var old_screen_tween = old_screen.create_tween().tween_property(old_screen, "global_position", -direction * camera.target_zoom * default_resolution, 2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		if destroy_old_screen : 
			old_screen_tween.finished.connect(
				func () : 
					if old_screen : old_screen.queue_free()
					old_screen = null)
		else:
			previous_screen_resource = current_screen_resource
			previous_scene_zoom = camera.zoom
			previous_scene_camera_position = camera.global_position
	current_screen_resource = new_screen_resource

## Can only be used if load_scene() was called previously with the destroy_old_screen parameter set to false
func load_previous_scene():
	if old_screen :
		var temp := old_screen
		old_screen = current_screen
		current_screen = temp
		direction = - direction
		current_screen_resource = previous_screen_resource
		slide_screens(previous_screen_resource, true, previous_scene_camera_position, previous_scene_zoom)

func reset_scene(reset_direction := Vector2(0, -1)):
	var scene := load_scene(current_screen_resource , reset_direction, true, true)
	if scene :
		Player.has_collectible = false
		for puzzle_piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces") :
			if puzzle_piece.is_dragging : puzzle_piece.stop_dragging()
		return scene
		
func _process(_delta):
	if discord_rpc : discord_rpc.run_callbacks()

func _init() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	
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

func  _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("Fullscreen") :
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else :
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
			
