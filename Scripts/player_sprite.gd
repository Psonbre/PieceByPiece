extends Node2D
class_name PlayerSprite

@onready var sprite : AnimatedSprite2D = $Sprite

var default_scale: Vector2

func _ready():
	visible = true
	default_scale = sprite.scale

func _process(_delta):
	var player: Player = get_tree().get_nodes_in_group("Player")[get_tree().get_node_count_in_group("Player") - 1]
	global_transform = player.global_transform

func squash(squash_strenght):
	squash_strenght = clampf(squash_strenght, 1.2, 1.4)
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(default_scale.x * squash_strenght, default_scale.y / squash_strenght), 0.07)
	tween.tween_property(sprite, "scale", default_scale, 0.07).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
func jump_stretch():
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(default_scale.x / 1.1, default_scale.y * 1.1), 0.1)
	tween.tween_property(sprite, "scale", default_scale, 0.8).set_ease(Tween.EASE_OUT)
	
func play(animation : String):
	if sprite : sprite.play(animation)

func pause():
	if sprite : sprite.pause()

func flip(flipped):
	if sprite : sprite.flip_h = flipped
