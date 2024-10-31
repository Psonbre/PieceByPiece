extends Node2D
class_name PlayerSprite

func _process(delta):
	global_transform = get_tree().get_first_node_in_group("Player").global_transform
