@tool
extends Node2D
class_name WorldSelectButton

@onready var overlay = $Overlay
@onready var play_icon = $Overlay/PlayIcon
@onready var animation_player = $AnimationPlayer
@onready var levels_text = $Overlay/Levels
@onready var collectibles_text = $Overlay/Collectibles

var default_scale : Vector2
var mouse_hover := false
var target_scale : Vector2
var world_completed : bool :
	get():
		return nb_of_completed_levels >= nb_of_levels
		
@export var nb_of_levels := 10 :
	set(value):
		nb_of_levels = value
		update_labels()
		
@export var nb_of_completed_levels := 0 :
	set(value):
		nb_of_completed_levels = value
		update_labels()
		
@export var nb_of_collectibles := 0 :
	set(value):
		nb_of_collectibles = value
		update_labels()

func _ready():
	default_scale = scale
	target_scale = default_scale
	update_labels()
	
func _process(delta):
	if Engine.is_editor_hint() : return
	scale = scale.move_toward(target_scale, abs((target_scale - scale).length()) * delta * 6.0)
	if play_icon :
		if mouse_hover :
			overlay.self_modulate = Color(1,1,1, move_toward(overlay.self_modulate.a, 0.1, delta / 2.0))
			play_icon.color = Color(1,1,1, move_toward(play_icon.color.a, 0.6, delta * 2.0))
		else :
			overlay.self_modulate = Color(1,1,1,move_toward(overlay.self_modulate.a, 0, delta / 2.0))
			play_icon.color = Color(1,1,1,move_toward(play_icon.color.a, 0, delta * 2.0))

func update_labels() :
	if levels_text : levels_text.text = str(nb_of_completed_levels) + "/" + str(nb_of_levels)
	if collectibles_text : collectibles_text.text = str(nb_of_collectibles) + "/" + str(nb_of_levels)

func _on_mouse_entered():
	if Engine.is_editor_hint() : return
	animation_player.play("Preview")
	mouse_hover = true
	target_scale = default_scale * 1.1

func _on_mouse_exited():
	if Engine.is_editor_hint() : return
	animation_player.stop()
	mouse_hover = false
	target_scale = default_scale
