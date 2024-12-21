extends Node2D
class_name Level
@export var world : SceneManager.WORLDS
@export var next_level : PackedScene
@onready var reset_level_cooldown: Timer = $ResetLevelCooldown
@onready var pause_menu: PauseMenu = $Control/LevelMenu
@export var background_gradient : Gradient

signal on_pause_input

var can_reset := true
var can_exit := true
var last_select_direction := Vector2.ZERO
var is_mouse_controlled := false :
	set(value):
		is_mouse_controlled = value
		if is_mouse_controlled : Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else : Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
var focused_piece : PuzzlePiece
const controller_cursor_speed := 2000.0

func _input(event):
	var scene_manager = SubSystemManager.get_scene_manager()

	if event is InputEventMouse :
		is_mouse_controlled = true

	# Handle zoom
	if Input.is_action_just_pressed("Zoom"):
		var cam = scene_manager.camera
		cam.target_zoom += Vector2(0.1, 0.1)
		cam.pan(cam.target_position, cam.target_zoom)

	if Input.is_action_just_pressed("Unzoom"):
		var cam = scene_manager.camera
		cam.target_zoom -= Vector2(0.1, 0.1)
		cam.pan(cam.target_position, cam.target_zoom)

	# Handle restart
	if Input.is_action_just_pressed("Reset"):
		_on_level_menu_on_restart_clicked()

	var select_input = Input.get_vector("SelectPieceLeft", "SelectPieceRight", "SelectPieceUp", "SelectPieceDown").normalized()
	var select_direction = select_input
	if select_direction.length() > 1.0 : select_direction = select_direction.normalized()
	
	if not PuzzlePiece.global_dragging and select_direction.is_normalized() and !last_select_direction.is_normalized():
		handle_controller_piece_select(select_direction, event)
		is_mouse_controlled = false
		
	last_select_direction = select_direction
	
func handle_controller_piece_select(select_direction : Vector2, event : InputEvent):
	var all_pieces = get_tree().get_nodes_in_group("PuzzlePieces").filter(func (p): return self.is_ancestor_of(p))
	if all_pieces.size() == 0:
		return

	var hovering_pieces = all_pieces.filter(func(p): return p.is_hovering)
	focused_piece = hovering_pieces.front() if hovering_pieces.size() > 0 else null

	if not focused_piece:
		all_pieces.front().focus()
		return
	
	if event is InputEventMouse :
		focused_piece.unfocus()
		return
	
	if select_direction == Vector2.ZERO:
		return

	var angle_tolerance = deg_to_rad(5.0)
	var max_angle_tolerance = deg_to_rad(90.0)
	var angle_increment = deg_to_rad(5.0)

	# Precompute angle_diff and distance for each piece
	var piece_info = []
	for piece in all_pieces:
		if piece == focused_piece:
			continue
		var dir_to_piece = piece.position - focused_piece.position
		if dir_to_piece == Vector2.ZERO:
			continue
		var angle_diff = abs(select_direction.angle_to(dir_to_piece))
		var distance = dir_to_piece.length()
		piece_info.append({
			"piece": piece,
			"angle_diff": angle_diff,
			"distance": distance
		})

	var best_piece: PuzzlePiece = null
	var best_distance = INF

	# Try widening the angle until we find a piece or reach max tolerance
	while angle_tolerance <= max_angle_tolerance and best_piece == null:
		for info in piece_info:
			if info.angle_diff <= angle_tolerance:
				if info.distance < best_distance:
					best_distance = info.distance
					best_piece = info.piece

		if best_piece == null:
			angle_tolerance += angle_increment

	if best_piece:
		focused_piece.unfocus()
		best_piece.focus()

func _ready() -> void:
	PuzzlePiece.global_dragging = false
	if get_tree().current_scene == self :
		SubSystemManager.get_scene_manager().load_level.call_deferred(world, load(scene_file_path), Vector2.ZERO)
		queue_free()
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces"):
		piece.shape.update_shape()
	find_child("Player").current_level = self


func _on_level_menu_on_quit_clicked():
	var scene_manager = SubSystemManager.get_scene_manager()
	if can_exit and scene_manager.old_screen != self and !Player.winning:
		if scene_manager.load_level_select(world) : can_exit = false


func _on_level_menu_on_restart_clicked():
	var scene_manager = SubSystemManager.get_scene_manager()
	if can_reset and scene_manager.old_screen != self and reset_level_cooldown.is_stopped() and !Player.winning:
		if scene_manager.reset_scene() : can_reset = false


func _on_level_menu_on_settings_clicked():
	var scene_manager = SubSystemManager.get_scene_manager()
	if scene_manager.old_screen != self and !Player.winning:
		scene_manager.load_settings_menu() 
