extends Area2D
class_name PuzzlePiece

@export var is_rotating_piece := false

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

var rotated_angle := 0.0
var target_rotated_angle := 0
var tilt_angle := 0.0
var drag_speed := 10.0
var is_dragging := false
var is_hovering := false
var velocity := Vector2.ZERO
var default_scale := Vector2(1.0, 1.0)
var connection_group := ConnectionGroup.new(self)

var start_drag_position := Vector2.ZERO
var start_drag_target_rotated_angle := 0.0
var start_drag_rotation := 0.0
var start_drag_tilt := 0.0

func _ready():
	door.get_node("CollisionShape2D").disabled = !door.visible 
	start_drag_position = global_position
	start_drag_target_rotated_angle = target_rotated_angle
	start_drag_rotation = global_rotation
	start_drag_tilt = tilt_angle
	default_scale = scale
	player_sprite.visible = true
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	attempt_connection()

func _input(event):
	if is_dragging && is_rotating_piece :
		if event.is_action_pressed("Rotate Right"):
			target_rotated_angle = target_rotated_angle + 90
			tilt_angle = 0
		if event.is_action_pressed("Rotate Left"):
			target_rotated_angle = target_rotated_angle - 90
			tilt_angle = 0

func _process(delta):
	if Input.is_action_just_pressed("Click") and is_hovering and !global_dragging:
		start_dragging()
	elif Input.is_action_just_released("Click") and is_dragging:
		stop_dragging()
		
	if shape.has_node("Player") && !Player.winning:
		shape.get_node("Player").global_rotation = 0 + tilt_angle
		
	if is_dragging:
		var target_position = get_global_mouse_position()
		var distance = target_position - global_position
		velocity = distance * drag_speed * delta
		global_position += velocity
		scale = scale.move_toward(default_scale * 1.1, 0.6 * delta)
		
		if velocity.length() > 0:
			var tilt_by = deg_to_rad(velocity.x) / 30.0
			var max_tilt = deg_to_rad(15)
			tilt_angle += tilt_by
			tilt_angle = clamp(tilt_angle, -max_tilt, max_tilt)
		
		rotated_angle = move_toward(rotated_angle, deg_to_rad(target_rotated_angle), abs(deg_to_rad(target_rotated_angle) - rotated_angle) * delta * 10.0)
		
		rotation = rotated_angle + tilt_angle
		
		var closest_compatible_connector = get_first_compatible_overlapping_connector()
		if closest_compatible_connector:
			ghost_piece.display(
				self, 
				closest_compatible_connector.get_adjacent_piece_position(false), 
				deg_to_rad(round(target_rotated_angle / 90.0) * 90),
				closest_compatible_connector.get_adjacent_piece_position(true), 
				closest_compatible_connector.puzzle_piece.tilt_angle + deg_to_rad(round(target_rotated_angle / 90.0) * 90)
			)
		else:
			ghost_piece.hide_display()
		
		if can_be_dropped():
			if is_rotating_piece :
				outline.material.set_shader_parameter('color', Vector4(0, 1, 0, 1))
			else :
				outline.material.set_shader_parameter('color', Vector4(1, 1, 1, 1))
		else:
			outline.material.set_shader_parameter('color', Vector4(1, 0, 0, 1))
			
	else:
		scale = scale.move_toward(default_scale, 2 * delta)
		if is_rotating_piece :
			outline.material.set_shader_parameter('color', Vector4(0, 1, 0, 1))
		else :
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
	start_drag_position = global_position
	start_drag_target_rotated_angle = target_rotated_angle % 360
	start_drag_rotation = global_rotation
	start_drag_tilt = tilt_angle
	is_dragging = true
	global_dragging = true
	attempt_connection()
	attempt_connection_on_all_other_pieces()
	
func stop_dragging():
	if abs(rad_to_deg(rotated_angle) - target_rotated_angle) > 15 : return #safeguard to prevent pieces being dropped at wierd angles
	if !can_be_dropped() : 
		cancel_drag()
		return
	ghost_piece.hide_display()
	
	set_player_sprites_visible(true)
	outline.outline_type = PuzzlePieceOutline.OutlineType.NORMAL
	z_index = 0
	is_dragging = false
	global_dragging = false
	scale = default_scale
	attempt_connection()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	attempt_connection_on_all_other_pieces()
	set_colliders_in_drag_mode(false)
	
func attempt_connection():
	if has_attempted_connection_this_tick: return
	has_attempted_connection_this_tick = true
	
	var compatible_connector = get_first_compatible_overlapping_connector()
	if compatible_connector != null :
		snap_to_connector(compatible_connector)
		
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	connect_all_sides()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	update_connection_group()
	
func attempt_connection_on_all_other_pieces():
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if piece != self : piece.attempt_connection()

func is_overlapping_other_piece():
	for piece in get_overlapping_areas():
		if piece is PuzzlePiece :
			return true
	return false

func clamp_player():
	if !shape.has_node("Player") : return
	var player = shape.get_node("Player")
	if player != null :
		var player_radius = player.collision_shape.shape.radius
		player.position = Vector2(clampf(player.position.x, left_connector.position.x + 20, right_connector.position.x - 20), clampf(player.position.y, top_connector.position.y + 20, bottom_connector.position.y - 20))

func cancel_drag():
	ghost_piece.hide_display()
	global_position = start_drag_position
	target_rotated_angle = start_drag_target_rotated_angle
	rotated_angle = deg_to_rad(start_drag_target_rotated_angle)
	tilt_angle = start_drag_tilt
	global_rotation = start_drag_rotation
	outline.outline_type = PuzzlePieceOutline.OutlineType.NORMAL
	z_index = 0
	player_sprite.visible = true
	is_dragging = false
	global_dragging = false
	scale = default_scale
	set_player_sprites_visible(true)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	attempt_connection()
	attempt_connection_on_all_other_pieces()
	set_colliders_in_drag_mode(false)
	
func snap_to_connector(connector : PuzzlePieceConnector):
	connector.puzzle_piece.global_rotation = deg_to_rad(round(connector.puzzle_piece.target_rotated_angle / 90.0) * 90)
	global_position = connector.get_adjacent_piece_position(false)
	global_rotation = deg_to_rad(round(target_rotated_angle / 90.0) * 90)
	tilt_angle = 0

func connect_all_sides():
	left_connector.connect_with_closest()
	right_connector.connect_with_closest()
	top_connector.connect_with_closest()
	bottom_connector.connect_with_closest()

func get_first_compatible_overlapping_connector() -> PuzzlePieceConnector:
	var connection_result = left_connector.get_first_compatible_overlapping_connector(is_dragging)
	if connection_result == null :
		connection_result = right_connector.get_first_compatible_overlapping_connector(is_dragging)
	if connection_result == null :
		connection_result = top_connector.get_first_compatible_overlapping_connector(is_dragging)
	if connection_result == null :
		connection_result = bottom_connector.get_first_compatible_overlapping_connector(is_dragging)
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
			if piece not in valid_pieces_to_overlap and not (is_dragging and piece is GhostPiece):
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
	if ghost_piece.displayed:
		return ghost_piece.valid_placement
	else :
		if !all_overlapping_pieces_have_compatible_overlapping_connectors() :
			return false
		if !all_connectors_can_be_dropped() :
			return false
		return true

func set_player_sprites_visible(shown : bool) :
	for sprite in get_tree().get_nodes_in_group("PlayerSprites") : 
		sprite.visible = shown
		

func update_all_connection_groups():
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces") :
		piece.update_connection_group()

func update_connection_group():
	var tested_pieces : Array[PuzzlePiece] = [self]
	connection_group = ConnectionGroup.new(self)
	add_piece_connections_to_connection_group(connection_group, self)
	while tested_pieces != connection_group.members :
		for piece in connection_group.members :
			if piece not in tested_pieces :
				add_piece_connections_to_connection_group(connection_group, piece)
				tested_pieces.append(piece)

func add_piece_connections_to_connection_group(cg: ConnectionGroup, piece: PuzzlePiece):
	if piece.left_connector.connected_to:
		cg.add_member(piece.left_connector.connected_to.puzzle_piece)
	if piece.right_connector.connected_to:
		cg.add_member(piece.right_connector.connected_to.puzzle_piece)
	if piece.top_connector.connected_to:
		cg.add_member(piece.top_connector.connected_to.puzzle_piece)
	if piece.bottom_connector.connected_to:
		cg.add_member(piece.bottom_connector.connected_to.puzzle_piece)

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
