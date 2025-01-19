extends Node2D
class_name PlayerSprite

@onready var stretch_parent: Node2D = $StretchParent
@onready var sprite : AnimatedSprite2D = $StretchParent/Sprite

var default_sprite_scale: Vector2
var default_stretch_parent_scale: Vector2
var puzzle_piece : PuzzlePiece

func _ready():
	visible = true
	default_sprite_scale = sprite.scale
	default_stretch_parent_scale = stretch_parent.scale
	var player_sprites := get_tree().get_nodes_in_group("PlayerSprites")
	if player_sprites.any(func (s) : return s != self and s.scene_file_path == scene_file_path and puzzle_piece.level == s.puzzle_piece.level) :
		for light : Light2D in find_children("*", "Light2D") :
			light.visible = false
			
func _process(_delta):
	var player: Player = get_tree().get_nodes_in_group("Player")[get_tree().get_node_count_in_group("Player") - 1]
	global_transform = player.global_transform

func squash(squash_strenght):
	squash_strenght = clampf(squash_strenght, 1.2, 1.4)
	var tween = create_tween()
	tween.tween_property(stretch_parent, "scale", Vector2(sign(default_stretch_parent_scale.x) * default_stretch_parent_scale.x * squash_strenght, default_stretch_parent_scale.y / squash_strenght), 0.07)
	tween.tween_property(stretch_parent, "scale", Vector2(sign(default_stretch_parent_scale.x)* default_stretch_parent_scale.x, default_stretch_parent_scale.y), 0.07).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	
func jump_stretch():
	var tween = create_tween()
	tween.tween_property(stretch_parent, "scale", Vector2(sign(default_stretch_parent_scale.x)*default_stretch_parent_scale.x / 1.1, default_stretch_parent_scale.y * 1.1), 0.1)
	tween.tween_property(stretch_parent, "scale", Vector2(sign(default_stretch_parent_scale.x)*default_stretch_parent_scale.x, default_stretch_parent_scale.y), 0.8).set_ease(Tween.EASE_OUT)
	
func play(animation : String):
	if sprite : 
		if sprite.sprite_frames.has_animation(animation) :
			sprite.play(animation)

func pause():
	if sprite : sprite.pause()

func flip(flipped):
	if sprite : 
		if flipped :
			create_tween().tween_property(sprite, "scale:x", -abs(default_sprite_scale.x), 0.05)
		else :
			create_tween().tween_property(sprite, "scale:x", abs(default_sprite_scale.x), 0.05)
