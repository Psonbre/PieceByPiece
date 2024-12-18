extends FloatingUI

var default_scale : Vector2
var mouse_hover := false
var enabled := true :
	set(value):
		enabled = value
		visible = value

@export var target_world_group : WorldSelectTree.TARGET_GROUPS
@export var target_focus_node : WorldSelectButton
@export var self_world_group : WorldSelectTree.TARGET_GROUPS
@export var required_completed_worlds : Array[WorldSelectButton]
@onready var tree : WorldSelectTree

func _ready():
	super._ready()
	default_scale = scale
	tree = find_parent("Tree")
	
func _process(delta):
	super._process(delta)

func update_enabled():
	enabled = requirements_fufilled()

func requirements_fufilled():
	for button in required_completed_worlds :
		if button and !button.world_completed :
			return false
	if self_world_group != tree.target_group :
		return false
	return true

func _on_mouse_entered():
	mouse_hover = true
	create_tween().tween_property(self, "scale", default_scale * 1.1, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_mouse_exited():
	mouse_hover = false
	create_tween().tween_property(self, "scale", default_scale * 1.0, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_pressed() -> void:
	tree.set_target_group(target_world_group)
	if target_focus_node : target_focus_node.grab_focus()
	else : tree.target_node.grab_focus()
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/transition.wav"), -5, 0.5 + (randf() - 0.5) / 4.0)
