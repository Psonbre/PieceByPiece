@tool
extends Area2D
class_name PuzzlePieceVisualConnector

enum ConnectorShape {FLAT = 0, CIRCLE = 1, TRIANGLE = 2, SQUARE = 3}
enum ConnectorType {BUMP = 1, HOLE = -1}

@onready var collision_shape : CollisionShape2D = $CollisionShape2D
@onready var puzzle_piece_shape = $"../.."

@export var shape := ConnectorShape.FLAT :
	set(value) :
		shape = value
		if (puzzle_piece_shape) : puzzle_piece_shape.update_shape()

@export var type := ConnectorType.BUMP : 
	set(value) :
		type = value
		if (puzzle_piece_shape) : puzzle_piece_shape.update_shape()

func update_shape(hole_radius : float):
	if shape == ConnectorShape.FLAT :
		var rectangle_shape = RectangleShape2D.new()
		rectangle_shape.size = Vector2(hole_radius, hole_radius * 2)
		collision_shape.shape = rectangle_shape
		collision_shape.position = Vector2(-hole_radius / 2 + 1,0)
	else :
		if type == ConnectorType.BUMP :
			var circle_shape = CircleShape2D.new()
			circle_shape.radius = hole_radius * 1.0
			collision_shape.shape = circle_shape
			collision_shape.position = Vector2.ZERO
		elif type == ConnectorType.HOLE :
			var rectangle_shape = RectangleShape2D.new()
			rectangle_shape.size = Vector2(hole_radius, hole_radius * 2)
			collision_shape.shape = rectangle_shape
			collision_shape.position = Vector2(-hole_radius / 2 + 1,0)
