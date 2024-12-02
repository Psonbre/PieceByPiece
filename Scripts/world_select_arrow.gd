extends FloatingUI

var default_scale : Vector2
var mouse_hover := false
var target_scale : Vector2
var enabled := true :
	set(value):
		enabled = value
		visible = value

@export var target_world_group : WorldSelectTree.TARGET_GROUPS
@export var self_world_group : WorldSelectTree.TARGET_GROUPS
@export var required_completed_worlds : Array[WorldSelectButton]
@onready var tree = $"../"

func _ready():
	super._ready()
	default_scale = scale
	target_scale = default_scale
	
func _process(delta):
	super._process(delta)
	scale = scale.move_toward(target_scale, abs((target_scale - scale).length()) * delta * 12.0)

func update_enabled():
	enabled = requirements_fufilled()

func requirements_fufilled():
	for button in required_completed_worlds :
		if !button.world_completed :
			return false
	if self_world_group != tree.target_group :
		return false
	return true

func _on_mouse_entered():
	mouse_hover = true
	target_scale = default_scale * 1.2

func _on_mouse_exited():
	mouse_hover = false
	target_scale = default_scale

func _input(event):
	if !enabled : return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mouse_hover:
		tree.set_target_group(target_world_group)
		SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/transition.wav"), -5, 0.5 + (randf() - 0.5) / 4.0)
