extends Control
class_name WorldSelectTree

@export var target_group : TARGET_GROUPS

enum TARGET_GROUPS {BASIC, ADVANCED, MIDDLE, LEFT, RIGHT, FINAL, DEMO}
var default_target_group
var target_node : Control

func _ready() -> void:
	default_target_group = target_group
	set_target_group(target_group)

func set_target_group(group_to_target : TARGET_GROUPS):
	target_group = group_to_target
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
		TARGET_GROUPS.DEMO:
			target_node = $Demo
			
	for arrow in get_tree().get_nodes_in_group("Arrow"):
		arrow.update_enabled()
	for group in get_tree().get_nodes_in_group("WorldGroup") :
		if group == old_target_node or group == target_node : group.visible = true
		elif is_ancestor_of(group) : group.visible = false
	
		create_tween().tween_property(self, "position", -target_node.position * scale, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)

func finish_transition_instantly():
	position = -target_node.start_position * scale
