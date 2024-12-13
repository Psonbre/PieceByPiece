extends Sprite2D
class_name MovingPlatform

const MOVING_PLATFORM_SPRITE = preload("res://Scenes/PuzzlePieces/moving_platform_sprite.tscn")
@onready var static_body_2d: StaticBody2D = $StaticBody2D
@onready var gear: Sprite2D = $Gear
@export var speed := 50.0
var direction := -1

var target_position : Vector2 :
	get():
		return current_track.to_global(current_track.points[point_index])
var point_index := 0
var current_track : Track
var puzzle_piece : PuzzlePiece :
	get():
		return get_parent().puzzle_piece

func _ready() -> void:
	visible = false
	switch_to_closest_track()
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces") :
		var sprite := MOVING_PLATFORM_SPRITE.instantiate()
		var shape = piece.get_node("Shape")
		shape.add_child.call_deferred(sprite)
		shape.move_child.call_deferred(sprite, shape.get_node("PlayerSprite").get_index() - 1)
		sprite.follows = self
		
func _process(delta: float) -> void:
	global_rotation = puzzle_piece.tilt_angle
	if puzzle_piece.is_dragging : return
	gear.rotate(2 * PI * delta * -direction)
	global_position = global_position.move_toward(target_position, speed * delta)
	static_body_2d.constant_linear_velocity = (target_position - global_position).normalized() * speed
	if global_position.is_equal_approx(target_position) :
		var new_point_index := point_index + direction
		if new_point_index < current_track.points.size() and new_point_index >= 0 :
			point_index = new_point_index
			target_position = current_track.to_global(current_track.points[point_index])
		else :
			var closest_other_track = get_closest_other_track()
			if closest_other_track and closest_other_track.get_closest_end(global_position).distance_to(global_position) < 20.0 :
				switch_to_closest_track()
			else:
				direction = -direction
				point_index += direction
				target_position =  current_track.to_global(current_track.points[point_index])

func get_closest_other_track():
	var closest_track : Track
	var closest_point := Vector2.INF
	for track : Track in get_tree().get_nodes_in_group("Tracks") :
		if track == current_track  || (track.puzzle_piece not in puzzle_piece.connection_group.members): continue
		var new_point : Vector2 = track.get_closest_end(global_position)
		if new_point.distance_squared_to(global_position) < closest_point.distance_squared_to(global_position) :
			closest_point = new_point
			closest_track = track
	return closest_track

func switch_to_closest_track():
	current_track = get_closest_other_track()
	reparent(current_track.get_parent())
	if current_track.get_closest_end(global_position) == current_track.to_global(current_track.points[0]) :
		direction = 1
		point_index = 0
	else :
		direction = -1
		point_index = current_track.points.size() - 1
