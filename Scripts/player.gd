class_name Player
extends CharacterBody2D

@onready var collision_shape = $CollisionShape2D
@onready var editor_sprite = $EditorSprite
@onready var step_sound_cooldown: Timer = $StepSoundCooldown
@onready var diggable_raycast: RayCast2D = $DiggableRaycast
@onready var wall_check: ShapeCast2D = $WallCheck
@onready var digging_particles: GPUParticles2D = $DiggingParticles
@onready var squash_cooldown: Timer = $SquashCooldown

const DEFAULT_SPEED := 300.0
const JUMP_VELOCITY := -400.0
var speed := DEFAULT_SPEED
var gravity := 980.0
var gravity_direction := Vector2(0,1)
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
var digging := false
var digging_direction := Vector2.ZERO
var non_tilted_velocity : Vector2
var locked := false

func _ready():
	default_scale = global_scale
	editor_sprite.visible = false
	play_animation("Idle");

func reset_proportions():
	global_scale = default_scale
	rotation = 0

func set_locked(should_lock : bool):
	locked = should_lock
	if locked :
		set_physics_process(false)
		return
	await get_tree().physics_frame
	if !locked : set_physics_process(true)
	
func _physics_process(delta):
	if non_tilted_velocity.y != 0 : last_vertical_speed = non_tilted_velocity.y
	
	#gravity
	if is_on_floor() :
		non_tilted_velocity.y = 0
	else :
		non_tilted_velocity.y += gravity * delta
		if squash_cooldown.is_stopped() :
			play_animation("Jump");
	
	#head bump	
	if is_on_ceiling() :
		non_tilted_velocity.y = 1
		
	#Horizontal movement
	var horizontal_input := Input.get_axis("Left","Right")
	if digging : 
		non_tilted_velocity = digging_direction * speed
	else : 
		non_tilted_velocity.x = horizontal_input * speed
	
	#Sprites and animations
	if horizontal_input != 0:
		if (horizontal_input  > 0) : set_flip(false)
		elif (horizontal_input < 0) : set_flip(true)
		if is_on_floor() : 
			play_animation("Moving");
			if step_sound_cooldown.is_stopped() : 
				step_sound_cooldown.start()
				SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/walk.ogg"), -3.0, (randf() - 0.5) * 0.5 + 1.0)
			
	elif is_on_floor():
		play_animation("Idle");

	#jump
	if is_on_floor() and Input.is_action_just_pressed("Jump") and !digging:
		SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/jump.ogg"), -7)
		non_tilted_velocity.y = JUMP_VELOCITY
	
	check_diggable(digging_direction if digging else Input.get_vector("Left", "Right", "Up", "Down"))
	
	velocity = non_tilted_velocity.rotated(global_rotation)
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

func check_diggable(input : Vector2):
	input = input.normalized()
	if abs(input.x) > abs(input.y):
		input = Vector2(sign(input.x), 0)
	else:
		input = Vector2(0, sign(input.y))  # Snap to vertical (up or down)
		
	diggable_raycast.position = -input * 20.0
	diggable_raycast.target_position = input * 45.0
	wall_check.rotation = input.angle()
	
	if diggable_raycast.is_colliding() :
		if wall_check.is_colliding() :
			digging_direction = -digging_direction
			wall_check.rotation = digging_direction.angle()
			speed = DEFAULT_SPEED * 2.0
		else :
			set_digging(true, diggable_raycast.target_position.normalized())
	else : 
		set_digging(false)

func set_digging(should_dig : bool, direction := Vector2.ZERO):
	if should_dig and !digging:
		digging = true
		set_collision_mask_value(4, false)
		non_tilted_velocity = Vector2.ZERO
		digging_direction = direction
		speed = DEFAULT_SPEED / 2.0
		gravity = 0
		digging_particles.emitting = true
	elif !should_dig and digging :
		digging = false
		set_collision_mask_value(4, true)
		speed = DEFAULT_SPEED
		gravity = 980
		digging_particles.emitting = false

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
	
	if !was_on_floor and is_on_floor():
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
				non_tilted_velocity = Vector2.ZERO
				set_physics_process(true)
			
	elif exiting_portal :
		global_position = global_position.move_toward(target_portal.global_position, 50 * delta)
		rotate(12 * delta)
		global_scale = global_scale.move_toward(default_scale, 5 * delta)
		if global_scale.x >= default_scale.x :
			target_portal.entered = true
			target_portal.cooldown.start()
			set_physics_process(true)
			non_tilted_velocity = Vector2.ZERO
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

func land(landing_speed):
	if squash_cooldown.is_stopped() :
		for player_sprite : PlayerSprite in get_tree().get_nodes_in_group("PlayerSprites"):
			player_sprite.squash(landing_speed / 100.0)
	last_vertical_speed = 0
