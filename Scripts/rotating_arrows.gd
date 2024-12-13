extends Sprite2D
class_name RotatingArrows

@onready var puzzle_piece = $"../.."

@export var default_color : Color
@export var selected_color : Color

@export var default_scale : Vector2
@export var selected_scale : Vector2

var color_lerp := 0.0
var scale_lerp := 0.0

func _ready():
	default_scale = scale
	visible = puzzle_piece.is_rotating_piece

func _process(delta):
	# Check for dragging and adjust scale and color lerp
	if puzzle_piece.is_dragging:
		z_index = 2
		scale_lerp = move_toward(scale_lerp, 1, (1 - scale_lerp) * 4 * delta)
		rotate(-PI * 0.5 * delta)
	else:
		z_index = 0
		scale_lerp = move_toward(scale_lerp, 0, scale_lerp * 4 * delta)
		
	if puzzle_piece.is_hovering:
		color_lerp = move_toward(color_lerp, 1, (1 - color_lerp) * 8 * delta)
	else:
		color_lerp = move_toward(color_lerp, 0, color_lerp * 4 * delta)

	# Apply color lerp to modulate
	modulate = default_color.lerp(selected_color, color_lerp)
	scale = default_scale.lerp(selected_scale, scale_lerp)
