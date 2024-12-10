extends Node2D
class_name WorldSelectButton

@onready var overlay = $Overlay
@onready var play_icon = $Overlay/PlayIcon
@onready var lock: Sprite2D = $Overlay/Lock
@onready var animation_player = $AnimationPlayer
@onready var levels_text = $Overlay/Levels
@onready var collectibles_text = $Overlay/Collectibles

var locked := true :
	set(value):
		locked = value
		lock.visible = locked
		play_icon.visible = !locked
		
var default_scale : Vector2
var mouse_hover := false
var target_scale := Vector2.ZERO
var world_completed : bool :
	get():
		return nb_of_completed_levels >= nb_of_levels

@export var nb_of_levels := 10	
var nb_of_completed_levels : int :
	get():
		return  SaveManager.get_completed_levels(world).size()		
var nb_of_collectibles : int :
	get():
		return SaveManager.get_collectible_levels(world).size()
@export var world : SceneManager.WORLDS
@export var required_completed_worlds : Array[WorldSelectButton]

func _ready():
	default_scale = scale
	target_scale = default_scale
	overlay.polygon = $Shape.polygon
	update_labels()
	locked = !required_completed_worlds.all(func(world) : return world.world_completed)
	print(locked)
	
func _process(delta):
	scale = scale.move_toward(target_scale, abs((target_scale - scale).length()) * delta * 6.0)
	if play_icon :
		if mouse_hover :
			play_icon.color = Color(1,1,1, move_toward(play_icon.color.a, 0.6, delta * 2.0))
		else :
			play_icon.color = Color(1,1,1,move_toward(play_icon.color.a, 0, delta * 2.0))

func update_labels() :
	if levels_text : levels_text.text = str(nb_of_completed_levels) + "/" + str(nb_of_levels)
	if collectibles_text : collectibles_text.text = str(nb_of_collectibles)

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

func _input(event: InputEvent) -> void:
	if mouse_hover and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and !locked:
		if SubSystemManager.get_scene_manager().load_level_select(world, Vector2(1,0)) :
			SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
			for group in get_tree().get_nodes_in_group("WorldGroup"):
				group.visible = group.is_ancestor_of(self)
			for arrow in get_tree().get_nodes_in_group("Arrow"):
				arrow.visible = false
