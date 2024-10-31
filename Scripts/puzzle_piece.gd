extends Area2D
class_name PuzzlePiece

@export var drag_speed := 10.0
static var global_dragging := false

@onready var ghost_piece : GhostPiece = $"../GhostPiece"
@onready var shape : PuzzlePieceShape = $Shape
@onready var outline : PuzzlePieceOutline = $Outline
@onready var right_connector : PuzzlePieceConnector = $Shape/Connectors/RightConnector
@onready var left_connector : PuzzlePieceConnector = $Shape/Connectors/LeftConnector
@onready var top_connector : PuzzlePieceConnector = $Shape/Connectors/TopConnector
@onready var bottom_connector : PuzzlePieceConnector = $Shape/Connectors/BottomConnector
@onready var player_sprite : AnimatedSprite2D = $Shape/PlayerSprite/Sprite
@onready var door = $Shape/Door

var has_attempted_connection_this_tick := false

var is_dragging := false
var is_hovering := false
var velocity := Vector2.ZERO
var default_scale := Vector2(1.0, 1.0)

var start_drag_position := Vector2.ZERO

func _ready():
	door.get_node("CollisionShape2D").disabled = !door.visible 
	start_drag_position = position
	default_scale = scale
	player_sprite.visible = true

func _process(delta):
	if Input.is_action_just_pressed("Click") and is_hovering and !global_dragging:
		start_dragging()
	elif Input.is_action_just_released("Click") and is_dragging:
		stop_dragging()

	if is_dragging:
		var target_position = get_global_mouse_position()
		var distance = target_position - global_position
		velocity = distance * drag_speed * delta
		global_position += velocity
		scale = scale.move_toward(default_scale * 1.1, 0.6 * delta)
		
		if velocity.length() > 0:
			var tilt_angle = velocity.x
			var max_tilt = deg_to_rad(15)
			tilt_angle = clamp(tilt_angle, -max_tilt, max_tilt)
			rotation = move_toward(rotation, tilt_angle, deg_to_rad(50) * velocity.length() * delta)
			
		var closest_compatible_connector = get_first_compatible_overlapping_connector()
		if closest_compatible_connector:
			ghost_piece.display(
				self, 
				closest_compatible_connector.get_adjacent_piece_position(false), 
				closest_compatible_connector.get_adjacent_piece_position(true), 
				closest_compatible_connector.puzzle_piece.global_rotation
			)
		else:
			ghost_piece.hide_display()
		
		if can_be_dropped():
			outline.material.set_shader_parameter('color', Vector4(1, 1, 1, 1))
		else:
			outline.material.set_shader_parameter('color', Vector4(1, 0, 0, 0.5))
			
	else:
		scale = scale.move_toward(default_scale, 2 * delta)
		outline.material.set_shader_parameter('color', Vector4(1, 1, 1, 1))
	
	has_attempted_connection_this_tick = false

	
func has_all_sides_connected():
	if !left_connector.has_connection : return false
	if !right_connector.has_connection : return false
	if !top_connector.has_connection : return false
	if !bottom_connector.has_connection : return false

func start_dragging():
	if Player.winning : return
	
	if shape.has_node("Player") :
		set_player_sprites_visible(false)
		player_sprite.visible = true 
	else : 
		player_sprite.visible = false
		
	clamp_player()
	set_colliders_in_drag_mode(true)
	outline.outline_type = PuzzlePieceOutline.OutlineType.MOVING
	z_index = 3
	start_drag_position = position
	is_dragging = true
	global_dragging = true
	attempt_connection()
	attempt_connection_on_all_other_pieces()
		
func stop_dragging():
	if !can_be_dropped() : 
		cancel_drag()
		return
	set_player_sprites_visible(true)
	outline.outline_type = PuzzlePieceOutline.OutlineType.NORMAL
	z_index = 0
	is_dragging = false
	global_dragging = false
	scale = default_scale
	attempt_connection()
	attempt_connection_on_all_other_pieces()
	set_colliders_in_drag_mode(false)
	
func attempt_connection():
	if has_attempted_connection_this_tick: return
	has_attempted_connection_this_tick = true
	ghost_piece.hide_display()
	
	var compatible_connector = get_first_compatible_overlapping_connector()
	if compatible_connector != null :
		snap_to_connector(compatible_connector)
	connect_all_sides()
	
func attempt_connection_on_all_other_pieces():
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece != self : piece.attempt_connection()

func is_overlapping_other_piece():
	for piece in get_overlapping_areas():
		if piece is PuzzlePiece :
			return true
	return false

func clamp_player():
	var player = shape.get_node("Player")
	if player != null :
		var player_radius = player.collision_shape.shape.radius
		player.position = Vector2(clampf(player.position.x, left_connector.position.x + 20, right_connector.position.x - 20), clampf(player.position.y, top_connector.position.y + 20, bottom_connector.position.y - 20))

func cancel_drag():
	position = start_drag_position
	rotation = 0
	outline.outline_type = PuzzlePieceOutline.OutlineType.NORMAL
	z_index = 0
	player_sprite.visible = true
	is_dragging = false
	global_dragging = false
	scale = default_scale
	await get_tree().physics_frame
	await get_tree().physics_frame
	attempt_connection()
	attempt_connection_on_all_other_pieces()
	set_colliders_in_drag_mode(false)
	
func snap_to_connector(connector : PuzzlePieceConnector):
	connector.puzzle_piece.rotation = 0
	global_position = connector.get_adjacent_piece_position(false)
	rotation = 0

func connect_all_sides():
	left_connector.connect_with_closest()
	right_connector.connect_with_closest()
	top_connector.connect_with_closest()
	bottom_connector.connect_with_closest()

func get_first_compatible_overlapping_connector() -> PuzzlePieceConnector:
	var connection_result = left_connector.get_compatible_overlapping_connector(is_dragging)
	if connection_result == null :
		connection_result = right_connector.get_compatible_overlapping_connector(is_dragging)
	if connection_result == null :
		connection_result = top_connector.get_compatible_overlapping_connector(is_dragging)
	if connection_result == null :
		connection_result = bottom_connector.get_compatible_overlapping_connector(is_dragging)
	return connection_result
	
func all_connectors_can_be_dropped():
	if !left_connector.can_be_dropped() : return false
	if !right_connector.can_be_dropped() : return false
	if !top_connector.can_be_dropped() : return false
	if !bottom_connector.can_be_dropped() : return false
	return true

func all_overlapping_pieces_have_compatible_overlapping_connectors():
	var valid_pieces_to_overlap = get_all_pieces_with_compatible_overlapping_connectors()
	for piece in get_overlapping_areas():
		if piece is PuzzlePiece :
			if piece not in valid_pieces_to_overlap :
				return false
	return true

func get_all_pieces_with_compatible_overlapping_connectors():
	var valid_pieces_to_overlap = []
	valid_pieces_to_overlap.append_array(left_connector.get_all_pieces_with_compatible_overlapping_connectors())
	valid_pieces_to_overlap.append_array(right_connector.get_all_pieces_with_compatible_overlapping_connectors())
	valid_pieces_to_overlap.append_array(top_connector.get_all_pieces_with_compatible_overlapping_connectors())
	valid_pieces_to_overlap.append_array(bottom_connector.get_all_pieces_with_compatible_overlapping_connectors())
	return valid_pieces_to_overlap

func set_colliders_in_drag_mode(drag_mode: bool):
	_set_colliders_recursive(self, drag_mode)
	shape.get_node("Foreground").collision_enabled = !drag_mode

func _set_colliders_recursive(node: Node, drag_mode: bool):
	if node.has_method("set_physics_process"):
		node.set_physics_process(!drag_mode)
	if node.has_method("set_collision_layer_value"):
		node.set_collision_layer_value(3, drag_mode)
		node.set_collision_layer_value(1, !drag_mode)
	for child in node.get_children():
		_set_colliders_recursive(child, drag_mode)

func can_be_dropped():
	if ghost_piece.displayed :
		return ghost_piece.valid_placement
	else :
		return all_overlapping_pieces_have_compatible_overlapping_connectors() && all_connectors_can_be_dropped()

func set_player_sprites_visible(visible : bool) :
	for sprite in get_tree().get_nodes_in_group("PlayerSprites") : 
		sprite.visible = visible

func _on_mouse_entered():
	is_hovering = true
	if !global_dragging:
		outline.z_index = 1

func _on_mouse_exited():
	is_hovering = false
	if !is_dragging:
		outline.z_index = -1

func _on_body_entered(player):
	if player is Player && player.get_parent() != shape && !is_dragging:
		player.add_overlapping_piece(self)

func _on_body_exited(player):
	if(player is Player):
		player.remove_overlapping_piece(self)
