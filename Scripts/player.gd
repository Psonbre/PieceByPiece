class_name Player
extends CharacterBody2D

@onready var collision_shape = $CollisionShape2D
@onready var editor_sprite = $EditorSprite

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
var overlapping_pieces = []
var default_scale
var was_on_floor := false
var last_vertical_speed :=  0.0
var current_level : Level
static var winning := false
static var entering_portal := false
static var exiting_portal := false
static var target_portal : Portal
static var has_collectible = false
var winning_door

func _ready():
	default_scale = global_scale
	editor_sprite.visible = false
	play_animation("Idle");

func reset_proportions():
	global_scale = default_scale
	rotation = 0
	
func _physics_process(delta):
	if velocity.y != 0 : last_vertical_speed = velocity.y
	
	if not is_on_floor() :
		velocity += get_gravity() * delta
		if abs(velocity.y) > 20.0 :
			play_animation("Jump");

	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		if (velocity.x  > 0) : set_flip(false)
		elif (velocity.x < 0) : set_flip(true)
		play_animation("Moving");
		if is_on_floor() : SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/walk.ogg"), -3)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() : play_animation("Idle");

	if is_on_floor() and Input.is_action_just_pressed("Jump") :
		SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/jump.ogg"), -7)
		velocity.y = JUMP_VELOCITY
			
	move_and_slide()
	
	if overlapping_pieces.size() > 0 :
		var closest_piece : PuzzlePiece = null
		var min_distance = INF
		for piece in overlapping_pieces:
			var distance = global_position.distance_to(piece.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_piece = piece
		if closest_piece != null && (find_parent("Shape") == null || closest_piece.shape != get_parent()):
			reparent(closest_piece.shape)
			reset_proportions()

func add_overlapping_piece(piece : PuzzlePiece):
	if piece not in overlapping_pieces:
		overlapping_pieces.push_back(piece)

func remove_overlapping_piece(piece_to_remove : PuzzlePiece):
	if overlapping_pieces.size() > 0 :
		var closest_piece : PuzzlePiece = null
		var min_distance = INF
		for piece in overlapping_pieces:
			var distance = global_position.distance_to(piece.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_piece = piece
			
		if piece_to_remove in overlapping_pieces && piece_to_remove != closest_piece:
			overlapping_pieces.remove_at(overlapping_pieces.find(piece_to_remove))
		
func win(door):
	if !winning :
		winning_door = door
		Player.winning = true
		set_physics_process(false)
		SaveManager.save_level_as_completed(current_level.world, current_level.scene_file_path)
		if has_collectible :
			SaveManager.save_level_as_collectible_collected(current_level.world, current_level.scene_file_path)

func teleport(portal : Portal):
	set_physics_process(false)
	portal.entered = true
	portal.cooldown.start()
	entering_portal = true
	target_portal = portal

func _process(delta):
	if !is_physics_processing() and editor_sprite.is_playing() :
		pause_animation()
	
	if !was_on_floor and is_on_floor() and abs(last_vertical_speed) > 10:
		land(last_vertical_speed)
	
	if (winning) :
		global_position = global_position.move_toward(winning_door.global_position, 10 * delta)
		rotate(12 * delta)
		global_scale = global_scale.move_toward(Vector2.ZERO, 1.0 * delta)
		if global_scale.x <= 0.1 :
			winning = false
			has_collectible = false
			if current_level.next_level :
				SubSystemManager.get_scene_manager().load_scene(current_level.next_level, Vector2(1,0))
			else :
				SubSystemManager.get_scene_manager().load_level_select(current_level.world)
				
			
	elif entering_portal :
		global_position = global_position.move_toward(target_portal.global_position, 50 * delta)
		rotate(12 * delta)
		global_scale = global_scale.move_toward(Vector2.ZERO, 5.0 * delta)
		if global_scale.x <= 0.1 :
			if target_portal.connected_portal :
				global_position = target_portal.connected_portal.global_position
				target_portal = target_portal.connected_portal
				entering_portal = false
				exiting_portal = true
			else :
				entering_portal = false
				global_scale = default_scale
				rotation = 0
				velocity = Vector2.ZERO
				set_physics_process(true)
			
	elif exiting_portal :
		global_position = global_position.move_toward(target_portal.global_position, 50 * delta)
		rotate(12 * delta)
		global_scale = global_scale.move_toward(default_scale, 5 * delta)
		if global_scale.x >= default_scale.x :
			target_portal.entered = true
			target_portal.cooldown.start()
			set_physics_process(true)
			velocity = Vector2.ZERO
			rotation = 0
			exiting_portal = false
			
	was_on_floor = is_on_floor()
	
func play_animation(animation : String):
	editor_sprite.play(animation)
	for player_sprite : PlayerSprite in get_tree().get_nodes_in_group("PlayerSprites"):
		player_sprite.play(animation)

func set_flip(flipped):
	editor_sprite.flip_h = flipped
	for player_sprite : PlayerSprite in get_tree().get_nodes_in_group("PlayerSprites"):
		player_sprite.flip(flipped)

func pause_animation():
	editor_sprite.pause()
	for player_sprite : PlayerSprite in get_tree().get_nodes_in_group("PlayerSprites"):
		player_sprite.pause()

func land(speed):
	for player_sprite : PlayerSprite in get_tree().get_nodes_in_group("PlayerSprites"):
		player_sprite.squash(speed / 100.0)
	last_vertical_speed = 0
