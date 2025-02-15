extends Control


func _input(event: InputEvent) -> void:
	if event is InputEventKey or event is InputEventMouse :
		visible = false
	if event is InputEventJoypadButton or event is InputEventJoypadMotion :
		visible = true
