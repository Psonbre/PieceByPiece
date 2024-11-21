extends Node2D
class_name PlayerSprite

@onready var sprite : AnimatedSprite2D = $Sprite

var squash_progress = 1.0
var squash_duration = 0.14
var squash_intensity = 0.07
var strength = 1.0
var landing_squash_multiplier := 1.0
var default_scale: Vector2

func _ready():
	visible = true
	default_scale = sprite.scale

func _process(_delta):
	var player: Player = get_tree().get_nodes_in_group("Player")[get_tree().get_node_count_in_group("Player") - 1]
	global_transform = player.global_transform
	
	var target_scale = default_scale
	
	if squash_progress < 1.0:
		squash_progress += _delta / squash_duration
		squash_progress = min(squash_progress, 1.0)
		
		var t = squash_progress * PI
		var ease_t = sin(t)
		
		var squash_amount = squash_intensity * ease_t * landing_squash_multiplier
		target_scale.x += squash_amount * 0.5 * default_scale.x
		target_scale.y -= squash_amount * default_scale.y
	else:
		target_scale.x -= (player.velocity.y / 3000.0) * strength * default_scale.x
		target_scale.y += (player.velocity.y / 5000.0) * strength * default_scale.y
	
	var max_scale = default_scale * 1.5
	var min_scale = default_scale * 0.5
	
	target_scale.x = clamp(target_scale.x, min_scale.x, max_scale.x)
	target_scale.y = clamp(target_scale.y, min_scale.y, max_scale.y)
	
	sprite.scale = target_scale


func squash(strength_value: float = 5.0):
	squash_progress = 0.0
	landing_squash_multiplier = strength_value
	
func play(animation : String):
	if sprite : sprite.play(animation)

func pause():
	if sprite : sprite.pause()

func flip(flipped):
	if sprite : sprite.flip_h = flipped
