extends Sprite2D
var follows : MovingPlatform
@onready var gear: Sprite2D = $Gear

func _process(delta: float) -> void:
	global_position = follows.global_position
	global_rotation = follows.global_rotation
	gear.global_rotation = follows.gear.global_rotation
