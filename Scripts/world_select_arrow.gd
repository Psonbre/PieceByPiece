extends FloatingUI

var default_scale : Vector2
var mouse_hover := false
var target_scale : Vector2
var enabled := true :
	set(value):
		enabled = value
		visible = value

@export var direction := Vector2()
@export var target_world : WorldSelectButton
@export var required_targeted_world : WorldSelectButton
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
	if required_targeted_world != tree.target_world :
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
		print(self)
		print(tree.target_position)
		tree.target_position += direction
		print(tree.target_position)
		tree.target_world = target_world
		for arrow in get_tree().get_nodes_in_group("Arrow"):
			arrow.update_enabled()
