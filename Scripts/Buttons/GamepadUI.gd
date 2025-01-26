extends Control
class_name GamepadUI

var IsMouseControlled := true
var Inputs = []
var can_exit := true
@export var FirstControl : Control

func _init():
	call_deferred("_initialize_inputs")
	
func _initialize_inputs():
	_get_focusable_children()
	
func _input(event):
	var current_screen := SubSystemManager.get_scene_manager().current_screen
	if not current_screen or not current_screen.is_ancestor_of(self) : return
	#Mouse inputs
	if (event is InputEventMouse):
		if (!IsMouseControlled):
			IsMouseControlled = true
			_set_inputs_focus_mode(Control.FOCUS_NONE)
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if event is not InputEventKey : Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		#First key input
		if IsMouseControlled:
			IsMouseControlled = false
			_set_inputs_focus_mode(Control.FOCUS_ALL)
			#Set focus on first control
			if FirstControl:
				_disable_first_controls_focus_neighbors()
				FirstControl.grab_focus()
		#Second key input
		elif FirstControl.has_focus():
				#Allows inputs navigation
				_reset_first_controls_focus_neighbors()
		if get_viewport().gui_get_focus_owner() == null :
			_set_inputs_focus_mode(Control.FOCUS_ALL)
			if FirstControl:
				_disable_first_controls_focus_neighbors()
				FirstControl.grab_focus()
			
func _set_inputs_focus_mode(mode : Control.FocusMode):
	for input in Inputs:
		input.focus_mode = mode

#First input cannot navigate to others inputs
func _disable_first_controls_focus_neighbors():
	FirstControl.focus_neighbor_bottom = FirstControl.get_path()
	FirstControl.focus_neighbor_top	 = FirstControl.get_path()
	FirstControl.focus_neighbor_bottom = FirstControl.get_path()
	FirstControl.focus_neighbor_bottom = FirstControl.get_path()

#Reset the neighbours to the automatics ones of Godot
func _reset_first_controls_focus_neighbors():
	FirstControl.focus_neighbor_bottom = ""
	FirstControl.focus_neighbor_top	 = ""
	FirstControl.focus_neighbor_bottom = ""
	FirstControl.focus_neighbor_bottom = ""
	
func _get_focusable_children():
	var focusable_nodes = []
	_find_focusable_children(self, focusable_nodes)
	Inputs = focusable_nodes

func _find_focusable_children(node, focusable_nodes):
	var children = node.get_children()
	for child in children:
		if child.has_method("get_focus_mode") and (child is BaseButton or child is Range):
			focusable_nodes.append(child)
		_find_focusable_children(child, focusable_nodes)
	


func _on_languages_slider_item_selected(index: int) -> void:
	pass # Replace with function body.
