extends FloatingUI

enum EXIT_MODE {DEFAULT, RESTORE}
var exit_mode := EXIT_MODE.DEFAULT
var exitting := false
@export var scroll_direction := Vector2(1,0)
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") :
		_on_pressed()

func _on_pressed() -> void:
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
	if exit_mode == EXIT_MODE.DEFAULT :
		if !exitting and SubSystemManager.get_scene_manager().load_main_menu(Vector2(-1,0)) :
			exitting = true
	elif exit_mode == EXIT_MODE.RESTORE :
		if !exitting :
			SubSystemManager.get_scene_manager().load_previous_scene()
			exitting = true

func _on_mouse_entered():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.05, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func _on_mouse_exited():
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * 1.0, 1).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
