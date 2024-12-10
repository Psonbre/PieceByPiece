extends Node
class_name Level
@export var world : SceneManager.WORLDS
@export var next_level : PackedScene
@onready var reset_level_cooldown: Timer = $ResetLevelCooldown
@export var background_gradient : Gradient
var can_reset := true
var can_exit := true

func _input(_event):
	if Engine.is_editor_hint() : return
	var scene_manager = SubSystemManager.get_scene_manager()
	if Input.is_action_just_pressed("Pause") and can_exit and scene_manager.old_screen != self:
		if scene_manager.load_level_select(world) : can_exit = false
	if Input.is_action_just_pressed("Reset") and can_reset and scene_manager.old_screen != self and reset_level_cooldown.is_stopped():
		if scene_manager.reset_scene() : can_reset = false
	if !PuzzlePiece.global_dragging :
		var cam = SubSystemManager.get_scene_manager().camera
		if Input.is_action_just_pressed("Zoom"):
			cam.target_zoom += Vector2(0.1, 0.1)
		if Input.is_action_just_pressed("Unzoom"):
			cam.target_zoom -= Vector2(0.1, 0.1)
		
		
func _ready() -> void:
	for piece : PuzzlePiece in get_tree().get_nodes_in_group("PuzzlePieces"):
		piece.shape.update_shape()
	find_child("Player").current_level = self
