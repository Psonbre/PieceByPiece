extends Control
class_name WorldSelectTree

@onready var target_node := $"Basic"

enum TARGET_GROUPS {BASIC, ADVANCED, MIDDLE, LEFT, RIGHT, FINAL}
var target_group : TARGET_GROUPS

func set_target_group(target_group : TARGET_GROUPS):
	self.target_group = target_group
	var old_target_node := target_node
	match target_group :
		TARGET_GROUPS.BASIC:
			target_node = $Basic
		TARGET_GROUPS.ADVANCED:
			target_node = $Advanced
		TARGET_GROUPS.MIDDLE:
			target_node = $MiddleGroup
		TARGET_GROUPS.LEFT:
			target_node = $LeftGroup
		TARGET_GROUPS.RIGHT:
			target_node = $RightGroup
		TARGET_GROUPS.FINAL:
			target_node = $Final
	for arrow in get_tree().get_nodes_in_group("Arrow"):
		arrow.update_enabled()
	for group in get_tree().get_nodes_in_group("WorldGroup") :
		if group == old_target_node or group == target_node : group.visible = true
		else : group.visible = false

func finish_transition_instantly():
	position = -target_node.position * scale

func _process(delta):
	var distance = -target_node.position * scale - position
	position += delta * distance * 4.0