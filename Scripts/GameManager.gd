extends Node2D

var old_screen : Node2D
var current_screen : Node2D
var hidden_x = -1920
var shown_x = 1920
var credits_screen

func _ready():
	current_screen = get_node("MainMenu")
	credits_screen = load("res://Scenes/Credits.tscn").instantiate()
	credits_screen.global_position.x = hidden_x
	add_child(credits_screen)

func load_level(level_name):
	if old_screen != null : return
	var level : Node2D = load("res://Scenes/Levels/" + level_name + ".tscn").instantiate()
	var new_cam : Camera2D = level.get_node("Camera2D")
	%Camera2D.target_position = new_cam.global_position
	%Camera2D.target_zoom = new_cam.zoom
	level.remove_child(new_cam)
	level.global_position.x = shown_x
	old_screen = current_screen
	current_screen = level
	
	get_tree().root.get_node("Game").add_child(level)

func load_main_menu():
	if current_screen == get_node("MainMenu") : return
	if old_screen != null : return
	if Player.current_level == 13 : Player.current_level = 1
	old_screen = current_screen
	current_screen = get_node("MainMenu")
	%Camera2D.target_position = Vector2.ZERO
	%Camera2D.target_zoom = Vector2.ONE
	
func load_credits():
	if old_screen != null : return
	old_screen = current_screen
	current_screen = credits_screen
	%Camera2D.target_position = Vector2.ZERO
	%Camera2D.target_zoom = Vector2.ONE
	
func _process(delta):
	if Input.is_action_just_pressed("Pause") :
		load_main_menu()
	if Input.is_action_just_pressed("Reset") && !Player.winning && old_screen == null :
		if Player.has_collectible :
			SubsystemManager.get_collectible_manager().remove_piece()
		load_level("Level" + str(Player.current_level))
		Player.has_collectible = false
	
	if (current_screen) : current_screen.global_position.x = move_toward(current_screen.global_position.x, shown_x / 2.0, 2500 * delta)
	if (old_screen) : 
		old_screen.global_position.x = move_toward(old_screen.global_position.x, hidden_x, 2500 * delta)
		if old_screen.global_position.x == hidden_x:
			if old_screen != get_node("MainMenu") && old_screen != credits_screen :
				old_screen.queue_free()
			old_screen = null
