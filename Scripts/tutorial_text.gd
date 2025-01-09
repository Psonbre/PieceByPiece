extends FloatingUI

var default_text : String
@export_multiline var controller_input := "[img=400][img]"
@export_multiline var mouse_and_keyboard_input := "[img=400][/img]"
func _ready() -> void:
	super._ready()
	default_text = self.text

func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse :
		self.text = mouse_and_keyboard_input
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion :
		self.text = controller_input
