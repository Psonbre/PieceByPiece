@tool
extends Area2D
class_name PuzzlePiece

enum THEME {MEDIEVAL, PIRATE, ALIEN, MINER}
const max_tilt := deg_to_rad(12)
const controller_drag_speed := 100.0
const THEME_RESOURCE_MAP = {
	THEME.MEDIEVAL : preload("res://Assets/PuzzlePieceThemes/medieval_theme.tres"),
	THEME.MINER : preload("res://Assets/PuzzlePieceThemes/miner_theme.tres"),
	THEME.ALIEN : preload("res://Assets/PuzzlePieceThemes/alien_theme.tres"),
	THEME.PIRATE : preload("res://Assets/PuzzlePieceThemes/pirate_theme.tres"),
} 

@export var is_rotating_piece := false

@export var theme := THEME.MEDIEVAL :
	set(value) :
		theme = value
		update_theme.call_deferred()
var theme_resource : PuzzlePieceTheme

static var global_dragging := false
static var dragging_piece : PuzzlePiece

@onready var level: Level = $".."
@onready var ghost_piece : GhostPiece = $"../GhostPiece"
@onready var shape : PuzzlePieceShape = $Shape
@onready var outline : PuzzlePieceOutline = $Outline
@onready var right_connector : PuzzlePieceConnector = $Shape/Connectors/RightConnector
@onready var left_connector : PuzzlePieceConnector = $Shape/Connectors/LeftConnector
@onready var top_connector : PuzzlePieceConnector = $Shape/Connectors/TopConnector
@onready var bottom_connector : PuzzlePieceConnector = $Shape/Connectors/BottomConnector
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var player_sprite : PlayerSprite
@export var drop_particles_scene: PackedScene
var foreground: TileMapLayer
var background: TileMapLayer
var dirt: TileMapLayer

var portal : Portal
var stop_dragging_next_physics_frame := false

var has_attempted_connection_this_tick := false

var rotated_angle := 0.0
var target_rotated_angle := 0
var tilt_angle := 0.0
var drag_speed := 12.0
var is_dragging := false
var is_hovering := false
var velocity := Vector2.ZERO
var default_scale := Vector2(1.0, 1.0)
var connection_group := ConnectionGroup.new(self)

var start_drag_position := Vector2.ZERO
var start_drag_target_rotated_angle := 0
var start_drag_rotation := 0.0
var start_drag_tilt := 0.0

func _ready():
	if Engine.is_editor_hint() : return
	portal = shape.get_node_or_null("Portal") 
	if portal : portal.puzzle_piece = self
	start_drag_position = global_position
	start_drag_target_rotated_angle = target_rotated_angle
	start_drag_rotation = global_rotation
	start_drag_tilt = tilt_angle
	default_scale = scale
	foreground = shape.get_node_or_null("Foreground")
	background = shape.get_node_or_null("Background")
	dirt = shape.get_node_or_null("Dirt")
	
	
	player_sprite = THEME_RESOURCE_MAP.get(theme).player_sprite.instantiate()
	player_sprite.puzzle_piece = self
	shape.add_child(player_sprite)
	shape.move_child(player_sprite, shape.get_node("Dirt").get_index())
	player_sprite.visible = true
	update_theme()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	attempt_connection()
	
func _input(event):
	if Engine.is_editor_hint() : return
	if is_dragging && is_rotating_piece :
		if event.is_action_pressed("Rotate Right"):
			target_rotated_angle = target_rotated_angle + 90
			tilt_angle = 0
		if event.is_action_pressed("Rotate Left"):
			target_rotated_angle = target_rotated_angle - 90
			tilt_angle = 0

func _process(delta):
	if Engine.is_editor_hint() : return
	if Input.is_action_just_pressed("Click") and is_hovering and !global_dragging and !PauseManager.is_paused:
		start_dragging()
	elif Input.is_action_just_released("Click") and is_dragging and !PauseManager.is_paused:
		stop_dragging()
		
	if shape.has_node("Player") && !Player.winning && !Player.entering_portal && !Player.exiting_portal:
		shape.get_node("Player").global_rotation = 0 + tilt_angle
		
	if is_dragging:
		var target_position : Vector2 
		
		if level.is_mouse_controlled :
			target_position = get_global_mouse_position()
		else :
			target_position = global_position + Input.get_vector("SelectPieceLeft", "SelectPieceRight", "SelectPieceUp", "SelectPieceDown") * controller_drag_speed
			
		var distance = target_position - global_position
		velocity = distance * drag_speed * delta
		global_position += velocity
		
		if velocity.length() > 0:
			var tilt_by = deg_to_rad(velocity.x) / 45.0
			tilt_angle += tilt_by
			tilt_angle = clamp(tilt_angle, -max_tilt, max_tilt)
		scale = scale.move_toward(default_scale * 1.1, 0.6 * delta)
		
		rotated_angle = move_toward(rotated_angle, deg_to_rad(target_rotated_angle), abs(deg_to_rad(target_rotated_angle) - rotated_angle) * delta * 10.0)
		
		rotation = rotated_angle + tilt_angle
		
		if can_be_dropped():
			outline.set_type(PuzzlePieceOutline.OutlineType.DRAGGING)
		else:
			outline.set_type(PuzzlePieceOutline.OutlineType.ERROR)
			
	else:
		scale = scale.move_toward(default_scale, 2 * delta)
	
	has_attempted_connection_this_tick = false

func update_theme():
	theme_resource = THEME_RESOURCE_MAP.get(theme)
	foreground = shape.get_node_or_null("Foreground")
	background = shape.get_node_or_null("Background")
	if foreground :
		for cell : Vector2i in foreground.get_used_cells() :
			foreground.set_cell(cell, theme_resource.tileset_id, foreground.get_cell_atlas_coords(cell))
	if background :
		for cell : Vector2i in background.get_used_cells() :
			background.set_cell(cell, theme_resource.tileset_id, background.get_cell_atlas_coords(cell))
	if shape and shape.has_node("Door") : shape.get_node("Door").set_texture(theme_resource.door_texture)
	if shape and shape.has_node("Collectible") : shape.get_node("Collectible/PointLight2D").energy = theme_resource.collectable_light_energy
	modulate = theme_resource.modulate
	update_lighting_range()
	
func update_lighting_range(call_for_all_piece := false):
	const dragging_light_layer := 512
	var emitters_mask : int = dragging_light_layer if is_dragging else theme_resource.light_layer
	var receivers_mask := emitters_mask + 1
	var player_sprites := get_tree().get_nodes_in_group("PlayerSprites")
	update_cells_occlusion_layer()
	
	if shape.has_node("Player") :
		for sprite in player_sprites.filter(func (s) : return s.scene_file_path == player_sprite.scene_file_path and level == s.puzzle_piece.level) :
			for light : Light2D in sprite.find_children("*", "Light2D", true, false) :
				light.visible = sprite == player_sprite
	
	var same_theme_sprites := player_sprites.filter(func (s) : return s != player_sprite and s.scene_file_path == player_sprite.scene_file_path and level == s.puzzle_piece.level)
	if same_theme_sprites.size() > 0 :
		same_theme_sprites[0].claim_theme_light()
		
	for light_affected_node : Node2D in get_tree().get_nodes_in_group("AffectedByInternalLight").filter(func(n) : return shape.is_ancestor_of(n)) :
		light_affected_node.light_mask = receivers_mask
	
	for light : Light2D in find_children("*", "Light2D", true, false) :
		light.shadow_item_cull_mask = emitters_mask
		light.range_item_cull_mask = emitters_mask
	
	if call_for_all_piece :
		for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces") : 
			if piece != self : piece.update_lighting_range()


func update_cells_occlusion_layer():
	for cell in foreground.get_used_cells() :
		foreground.set_cell(cell, theme_resource.tileset_id, foreground.get_cell_atlas_coords(cell), 1 if is_dragging else 0)
	for cell in background.get_used_cells() :
		background.set_cell(cell, theme_resource.tileset_id, background.get_cell_atlas_coords(cell), 1 if is_dragging else 0)
	if dirt :
		for cell in dirt.get_used_cells() :
			dirt.set_cell(cell, 1, dirt.get_cell_atlas_coords(cell), 1 if is_dragging else 0)
	
func has_all_sides_connected():
	if !left_connector.has_connection : return false
	if !right_connector.has_connection : return false
	if !top_connector.has_connection : return false
	if !bottom_connector.has_connection : return false

func start_dragging():
	if SubSystemManager.get_scene_manager().current_screen != level : return
	if Player.winning || Player.entering_portal || Player.exiting_portal : return
	if shape.has_node("Player") :
		var player : Player = shape.get_node("Player")
		if player.digging : return
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/piece_pickup.wav"), -7)
	
	if shape.has_node("Player") :
		set_player_sprites_visible(false)
		player_sprite.visible = true
	else : 
		player_sprite.visible = false
	
	clamp_player()
	set_colliders_in_drag_mode(true)
	outline.outline_type = PuzzlePieceOutline.OutlineType.DRAGGING
	z_index = 5
	start_drag_position = global_position
	start_drag_target_rotated_angle = target_rotated_angle % 360
	start_drag_rotation = global_rotation
	start_drag_tilt = tilt_angle
	is_dragging = true
	global_dragging = true
	dragging_piece = self
	update_lighting_range()
	attempt_connection()
	attempt_connection_on_all_other_pieces()
	
func stop_dragging():
	is_dragging = false
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	if ghost_piece.displayed :
		var test = ghost_piece.get_all_incompatible_overlapping_pieces()
		for area in test :
			area.global_position = get_available_puzzle_piece_position(area.global_position)
		ghost_piece.update_placement_validity()
	
	if !can_be_dropped() or abs(rad_to_deg(rotated_angle) - target_rotated_angle) > 15 || Player.winning || Player.entering_portal || Player.exiting_portal: 
		cancel_drag()
		return
		
	ghost_piece.hide_display()
	
	set_player_sprites_visible(true)
	z_index = 0
	global_dragging = false
	dragging_piece = null
	scale = default_scale
	var old_position = global_position
	update_lighting_range()
	attempt_connection()
	
	if drop_particles_scene : 
		var drop_particles = drop_particles_scene.instantiate()
		drop_particles.global_position = global_position
		get_tree().root.add_child(drop_particles)
	if !global_position.is_equal_approx(old_position) :
		SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/piece_click.ogg"), -13)
	
	attempt_connection_on_all_other_pieces()
	set_colliders_in_drag_mode(false)
	
	outline.set_type(PuzzlePieceOutline.OutlineType.NORMAL)

func get_available_puzzle_piece_position(starting_position: Vector2) -> Vector2:
	var puzzle_piece_radius = 175.0  # Approx half-size if your pieces are 320x320
	var angle_step_degrees = 5
	var max_search_radius = 2000.0

	# 1) Compute the base angle from self to starting_position
	var dir_vector = starting_position - self.global_position
	var base_angle_deg = rad_to_deg(dir_vector.angle())  
	# e.g. if starting_position is left of self, base_angle_deg ~ 180

	# 2) Gather existing piece positions
	var occupied_positions = []
	for puzzle_piece in get_tree().get_nodes_in_group("PuzzlePieces"):
		if puzzle_piece.global_position != starting_position : occupied_positions.append(puzzle_piece.global_position)

	# 3) Quick check: if starting spot is free, return it
	if not is_position_occupied(starting_position, occupied_positions, puzzle_piece_radius):
		return starting_position

	# 4) Spiral outward: radius from 1..max, angles from base_angle onward
	for r in range(1, int(max_search_radius)):
		for offset_deg in range(0, 360, angle_step_degrees):
			# Shift angle by base_angle, wrap around 0..360
			var current_deg = fposmod(base_angle_deg + offset_deg, 360)
			var rad = deg_to_rad(current_deg)

			# Compute the candidate position
			var candidate_pos = starting_position + Vector2(r, 0).rotated(rad)

			if not is_position_occupied(candidate_pos, occupied_positions, puzzle_piece_radius):
				return candidate_pos

	# If no free spot found within max_search_radius, return something default
	return Vector2.ZERO

func is_position_occupied(
	candidate_position: Vector2,
	occupied_positions: Array,
	puzzle_piece_radius: float
) -> bool:
	# Example: treat pieces as circles of radius `puzzle_piece_radius`
	for occupied_pos in occupied_positions:
		if candidate_position.distance_to(occupied_pos) < puzzle_piece_radius * 2.0:
			# Overlaps an existing piece
			return true
	return false

	
func attempt_connection():
	if has_attempted_connection_this_tick: return
	has_attempted_connection_this_tick = true
	
	var compatible_connector = get_first_compatible_overlapping_connector()
	if compatible_connector != null :
		snap_to_connector(compatible_connector)
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	connect_all_sides()
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
		player.position = Vector2(clampf(player.position.x, left_connector.position.x + 20, right_connector.position.x - 20), clampf(player.position.y, top_connector.position.y + 20, bottom_connector.position.y - 20))

func cancel_drag():
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/piece_drop.wav"), 5, 0.5, 0.05)
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
	dragging_piece = null
	scale = default_scale
	set_player_sprites_visible(true)
	update_lighting_range()
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
	shape.update_shape()
	

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

func get_all_incompatible_overlapping_pieces():
	var invalid_overlapping_pieces = []
	invalid_overlapping_pieces.append_array(get_overlapping_areas().filter(func (a) : return a is PuzzlePiece and a not in get_all_pieces_with_compatible_overlapping_connectors()))
	invalid_overlapping_pieces.append_array(left_connector.get_all_incompatible_overlapping_pieces())
	invalid_overlapping_pieces.append_array(right_connector.get_all_incompatible_overlapping_pieces())
	invalid_overlapping_pieces.append_array(top_connector.get_all_incompatible_overlapping_pieces())
	invalid_overlapping_pieces.append_array(bottom_connector.get_all_incompatible_overlapping_pieces())
	var dedup := []
	for piece in invalid_overlapping_pieces :
		if piece not in dedup and !piece is GhostPiece and piece != self:
			dedup.append(piece)
	return dedup

func set_colliders_in_drag_mode(drag_mode: bool):
	_set_colliders_recursive(self, drag_mode)
	shape.get_node("Foreground").collision_enabled = !drag_mode
	if shape.has_node("Dirt") : shape.get_node("Dirt").collision_enabled = !drag_mode
	set_collision_mask_value(1, true)
	
func _set_colliders_recursive(node: Node, drag_mode: bool) -> void:
	if node is not PuzzlePiece :
		if node is Player:
			node.set_locked(drag_mode)
		elif node.has_method("set_physics_process"):
			node.set_physics_process(!drag_mode)

	if node.has_method("set_collision_layer_value"):
		node.set_collision_layer_value(3, drag_mode)
		node.set_collision_layer_value(1, !drag_mode)

		var has_special_parent = node.find_parent("Colliders") or node.find_parent("Connectors")
		if not has_special_parent:
			node.set_collision_mask_value(3, drag_mode)
			node.set_collision_mask_value(1, !drag_mode)

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
	connect_portals()
	
func connect_portals():
	var portals = connection_group.members.filter(
		func(member): return member.portal != null
	).map(
		func(member): return member.portal
	)
	
	if portals.size() == 2 :
		portals[0].activate()
		portals[0].connected_portal = portals[1] 
		portals[1].activate()
		portals[1].connected_portal = portals[0]
	else :
		for portal_in_group in portals :
			portal_in_group.deactivate()
	
func add_piece_connections_to_connection_group(cg: ConnectionGroup, piece: PuzzlePiece):
	if piece.left_connector.connected_to:
		cg.add_member(piece.left_connector.connected_to.puzzle_piece)
	if piece.right_connector.connected_to:
		cg.add_member(piece.right_connector.connected_to.puzzle_piece)
	if piece.top_connector.connected_to:
		cg.add_member(piece.top_connector.connected_to.puzzle_piece)
	if piece.bottom_connector.connected_to:
		cg.add_member(piece.bottom_connector.connected_to.puzzle_piece)

func focus() :
	if PauseManager.is_paused : return
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces") :
		if piece != self : piece.unfocus()
	is_hovering = true
	if !global_dragging:
		outline.set_type(PuzzlePieceOutline.OutlineType.HIGHLIGHT)

func unfocus():
	if PauseManager.is_paused : return
	is_hovering = false
	if !is_dragging:
		outline.set_type(PuzzlePieceOutline.OutlineType.NORMAL)
	

func _on_mouse_entered():
	if Engine.is_editor_hint() : return
	if level.is_mouse_controlled :
		focus()
	
func _on_mouse_exited():
	if Engine.is_editor_hint() : return
	if level.is_mouse_controlled :
		unfocus()
	
func _on_body_entered(player):
	if Engine.is_editor_hint() : return
	if PauseManager.is_paused : return
	if player is Player && player.get_parent() != shape && !is_dragging:
		player.add_overlapping_piece(self)

func _on_body_exited(player):
	if Engine.is_editor_hint() : return
	if PauseManager.is_paused : return
	if(player is Player):
		player.remove_overlapping_piece(self)
