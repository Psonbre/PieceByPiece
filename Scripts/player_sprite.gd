extends AnimatedSprite2D

func _process(delta):
	global_position = get_tree().get_first_node_in_group("Player").global_position
