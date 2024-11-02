extends Node2D
class_name PlayerSprite

func _process(_delta):
	global_transform = get_tree().get_nodes_in_group("Player")[get_tree().get_node_count_in_group("Player") - 1].global_transform
