extends GamepadUI
class_name WorldSelectTree

@export var target_group : TARGET_GROUPS

enum TARGET_GROUPS {BASIC, ADVANCED, PORTAL_MINING, GRAVITY_KEY, ROTATING_PLATFORM, FINAL, DEMO}
var default_target_group
var target_node : WorldSelectButton
var current_tween : Tween

func _ready() -> void:
	default_target_group = target_group
	set_target_group.call_deferred(target_group)
			
func set_target_group(group_to_target : TARGET_GROUPS):
	target_group = group_to_target
	var old_target_node := target_node
	
	match target_group :
		TARGET_GROUPS.BASIC:
			target_node = $"BasicWorldContainer/Basic World"
		TARGET_GROUPS.ADVANCED:
			target_node = $"AdvancedWorldContainer/Advanced World"
		TARGET_GROUPS.PORTAL_MINING:
			target_node = $"ThemedWorldsContainer/PortalMiningWorldsContainer/PortalMiningWorldContainer/Dirt Portal World"
		TARGET_GROUPS.GRAVITY_KEY:
			target_node = $"ThemedWorldsContainer/GravityKeyWorldsContainer/GravityKeyWorldContainer/Gravity Key World"
		TARGET_GROUPS.ROTATING_PLATFORM:
			target_node = $"ThemedWorldsContainer/RotatingPlatformWorldsContainer/RotatingPlatformWorldContainer/Rotating Piece Platform World"
		TARGET_GROUPS.FINAL:
			target_node = $"FinalWorldContainer/Final World"
		TARGET_GROUPS.DEMO:
			target_node = $"DemoWorldContainer/Demo World"
			
	for arrow in get_tree().get_nodes_in_group("Arrow"):
		arrow.update_enabled()
	FirstControl = target_node
	current_tween = create_tween()
	current_tween.tween_property(self, "position", -get_button_relative_position(target_node) + Vector2(size.x / 2.0 - 128, 0), 1.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	
func finish_transition_instantly():
	if target_node : set_target_group(default_target_group)
	if current_tween : current_tween.custom_step(99)

func get_button_relative_position(world_button : WorldSelectButton):
	var relative_position = world_button.position * world_button.scale
	var current_parent = world_button.get_parent()
	
	while current_parent != self :
		relative_position += current_parent.position * current_parent.scale
		current_parent = current_parent.get_parent()
		
	return relative_position
