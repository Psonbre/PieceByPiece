extends Control

@onready var menu = $Container/DropdownSection/DropDownMenu
@export var hiddenPosition : Vector2
@export var showPosition : Vector2
@export var animationDuration : float = 1

signal on_restart_clicked
signal on_quit_clicked
signal on_settings_clicked

var menu_open : bool = false
var current_animation_tween: Tween

func _ready():
	menu.position = hiddenPosition

func _on_drop_down_menu_pressed():
	#Cancel any other animation
	if current_animation_tween :
		current_animation_tween.kill()
		
	#Close dropdown
	if (menu_open):
		move_dropdown(hiddenPosition)
	#Open dropdown
	else:
		move_dropdown(showPosition)
		
	
func move_dropdown(final_position : Vector2):
	var duration : float = calculate_animation_duration(final_position)
	var animation = create_tween()
	current_animation_tween = animation
	animation.set_trans(Tween.TRANS_CUBIC)
	animation.tween_property(menu,"position", final_position, duration)
	animation.play()
	menu_open = !menu_open
	
func calculate_animation_duration(finalPosition : Vector2):
	#Get the reverse position of the final position
	var default_start_position : Vector2 = get_default_starting_position(finalPosition)
	#Calculate pourcentage movement
	var pourcentage : float = calculate_pourcentage_movement(default_start_position, finalPosition)
	#Calculate movement speed
	return calculate_movement_speed(pourcentage)
	
func get_default_starting_position(finalPosition :  Vector2):
	var default_start_position : Vector2
	if finalPosition == hiddenPosition:
		default_start_position = showPosition
	else:
		default_start_position = hiddenPosition
	return default_start_position
	
func calculate_pourcentage_movement(start : Vector2, destination : Vector2):
	var totalDistance : float = start.distance_to(destination)
	var actualDistance : float = menu.position.distance_to(destination)
	return actualDistance / totalDistance
	
func calculate_movement_speed(movementPourcentage : float):
	return movementPourcentage * animationDuration


func _on_quit_button_pressed():
	emit_signal("on_quit_clicked")

func _on_restart_button_pressed():
	emit_signal("on_restart_clicked")

func _on_settings_button_pressed():
	emit_signal("on_settings_clicked")


func _on_level_on_pause_input():
	_on_drop_down_menu_pressed()