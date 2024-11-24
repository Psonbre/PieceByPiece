extends Node2D
class_name SceneManager

@onready var camera = %Camera2D

var old_screen : Node2D
var current_screen : Node2D
var default_resolution = Vector2(2560, 1440)
var direction = Vector2(-1, 0)

const CREDITS = preload("res://Scenes/Menus/Credits.tscn")
const MAIN_MENU = preload("res://Scenes/Menus/MainMenu.tscn")
const WORLD_SELECT = preload("res://Scenes/Menus/WorldSelect.tscn")

func load_main_menu(new_direction := Vector2(1, 0)):
	load_scene(MAIN_MENU, new_direction)

func load_world_select_menu(new_direction := Vector2(1, 0)):
	load_scene(WORLD_SELECT, new_direction)

func load_credits_menu(new_direction := Vector2(1, 0)):
	load_scene(CREDITS, new_direction)

func load_scene_from_path(scene_path : String, new_direction := Vector2(1, 0)):
	return load_scene(load(scene_path), new_direction)

func load_scene(scene_resource : Resource, new_direction := Vector2(1, 0)):
	if old_screen != null: return
	var scene = scene_resource.instantiate()
	var new_cam: Camera2D = scene.get_node("Camera2D")
	camera.target_position = new_cam.global_position
	camera.target_zoom = new_cam.zoom
	scene.remove_child(new_cam)
	
	# Set the starting position of the new screen based on direction
	scene.global_position = new_direction * camera.target_zoom * default_resolution
	
	old_screen = current_screen
	current_screen = scene
	
	direction = new_direction  # Update the global direction
	
	add_child(scene)
	return scene

func _process(delta):
	if Input.is_action_just_pressed("Reset") :
		reset_level()
	
	if current_screen:
		# Target position for the new screen
		var target_position = Vector2(0, 0)
		var speed = maxf((current_screen.global_position - target_position).length() * 3, 0) * delta
		current_screen.global_position = current_screen.global_position.move_toward(target_position, speed)
	
	if old_screen:
		# Target position for the old screen (opposite of the direction)
		var target_position = -direction * camera.target_zoom * default_resolution
		var speed = maxf((old_screen.global_position - target_position).length() * 3, 0) * delta
		old_screen.global_position = old_screen.global_position.move_toward(target_position, speed)
		
		if (old_screen.global_position - target_position).length() < 100:
			old_screen.queue_free()
			old_screen = null

func reset_level() :
	if !Player.winning and old_screen == null:
		if Player.has_collectible:
			SubSystemManager.get_collectible_manager().remove_piece()
		load_scene_from_path("res://Scenes/Levels/Level" + str(Player.current_level) + ".tscn", Vector2(0,-1))
		Player.has_collectible = false
