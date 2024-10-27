class_name Player
extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
var overlapping_pieces = []
var default_scale
static var current_level := 1
static var winning := false
var winning_door
static var has_collectible = false

func _ready():
	default_scale = global_scale
	animated_sprite_2d.play("Idle");

func reset_proportions():
	global_scale = default_scale
	rotation = 0
	
func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

	var direction = Input.get_axis("Left", "Right")
	if direction:
		velocity.x = direction * SPEED
		if (velocity.x  > 0) : animated_sprite_2d.flip_h = false
		elif (velocity.x < 0) : animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("Moving");
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/walk.ogg", -3)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() : animated_sprite_2d.play("Idle");

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		animated_sprite_2d.play("Jump");
		SubsystemManager.get_sound_manager().play_sound("res://Assets/Sounds/jump.ogg", -7)
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
		if closest_piece != null && (find_parent("Shape") == null || closest_piece.get_node("Shape") != get_parent()):
			reparent(closest_piece.get_node("Shape"))
			reset_proportions()

func add_overlapping_piece(piece : PuzzlePiece):
	if piece not in overlapping_pieces:
		overlapping_pieces.push_back(piece)

func remove_overlapping_piece(piece : PuzzlePiece):
	if piece in overlapping_pieces:
		overlapping_pieces.remove_at(overlapping_pieces.find(piece))

func win(door):
	if !winning :
		winning_door = door
		Player.winning = true
		set_physics_process(false)

func _process(delta):
	if (winning) :
		global_position = global_position.move_toward(winning_door.global_position, 10 * delta)
		rotate(12 * delta)
		global_scale = global_scale.move_toward(Vector2.ZERO, 1 * delta)
		if global_scale.x <= 0.1 :
			winning = false
			current_level += 1
			has_collectible = false
			print("Level" + str(current_level))
			get_tree().root.get_node("Game").load_level("Level" + str(current_level))
