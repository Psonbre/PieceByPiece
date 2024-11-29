extends Node
class_name Level
@export var world : SceneManager.WORLDS
@export var next_level : PackedScene
@onready var reset_level_cooldown: Timer = $ResetLevelCooldown
var can_reset := true
var can_exit := true

func _input(_event):
	var scene_manager = SubSystemManager.get_scene_manager()
	if Input.is_action_just_pressed("Pause") and can_exit and scene_manager.old_screen != self:
		can_exit = false
		scene_manager.load_level_select(world)
	if Input.is_action_just_pressed("Reset") and can_reset and scene_manager.old_screen != self and reset_level_cooldown.is_stopped():
		can_reset = false 
		scene_manager.reset_scene()
		
func _ready() -> void:
	find_child("Player").current_level = self
