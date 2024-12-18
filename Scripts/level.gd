extends Node2D
class_name Level
@export var world : SceneManager.WORLDS
@export var next_level : PackedScene
@onready var reset_level_cooldown: Timer = $ResetLevelCooldown
@export var background_gradient : Gradient

signal on_pause_input

var can_reset := true
var can_exit := true

func _input(_event):
	if Engine.is_editor_hint() : return
	var scene_manager = SubSystemManager.get_scene_manager()
	if Input.is_action_just_pressed("Pause"):
		emit_signal("on_pause_input")
	if Input.is_action_just_pressed("Reset"):
		_on_level_menu_on_restart_clicked()
	if !PuzzlePiece.global_dragging :
		var cam = SubSystemManager.get_scene_manager().camera
		if Input.is_action_just_pressed("Zoom"):
			cam.target_zoom += Vector2(0.1, 0.1)
		if Input.is_action_just_pressed("Unzoom"):
			cam.target_zoom -= Vector2(0.1, 0.1)
		
		
func _ready() -> void:
	if get_tree().current_scene == self :
		SubSystemManager.get_scene_manager().load_level.call_deferred(world, load(scene_file_path), Vector2.ZERO)
		queue_free()
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces"):
		piece.shape.update_shape()
	find_child("Player").current_level = self


func _on_level_menu_on_quit_clicked():
	var scene_manager = SubSystemManager.get_scene_manager()
	if can_exit and scene_manager.old_screen != self and !Player.winning:
		if scene_manager.load_level_select(world) : can_exit = false


func _on_level_menu_on_restart_clicked():
	var scene_manager = SubSystemManager.get_scene_manager()
	if can_reset and scene_manager.old_screen != self and reset_level_cooldown.is_stopped() and !Player.winning:
		if scene_manager.reset_scene() : can_reset = false


func _on_level_menu_on_settings_clicked():
	var scene_manager = SubSystemManager.get_scene_manager()
	if scene_manager.old_screen != self and !Player.winning:
		scene_manager.load_settings_menu() 
