extends Node2D
class_name GameManager

var old_screen : Node2D
var current_screen : Node2D
var default_resolution = Vector2(2560, 1440)
@onready var camera = %Camera2D
var direction = Vector2(-1, 0)  # Store the direction globally for use in _process

func _ready():
	current_screen = get_node("MainMenu")
	print(get_tree().get_music_manager())

func load_scene(scene_path, new_direction := Vector2(1, 0)):
	if old_screen != null: return
	var scene: Node2D = load(scene_path).instantiate()
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

func _process(delta):
	if Input.is_action_just_pressed("Reset") and !Player.winning and old_screen == null:
		if Player.has_collectible:
			SubSystemManager.get_collectible_manager().remove_piece()
		load_scene("res://Scenes/Levels/Level" + str(Player.current_level) + ".tscn", Vector2(0,-1))
		Player.has_collectible = false
	
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
