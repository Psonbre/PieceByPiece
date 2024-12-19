extends Button
class_name WorldSelectButton

@onready var overlay = $Overlay
@onready var play_icon = $Overlay/PlayIcon
@onready var lock: Sprite2D = $Overlay/Lock
@onready var animation_player = $AnimationPlayer
@onready var levels_text = $Overlay/Levels
@onready var collectibles_text = $Overlay/Collectibles
@onready var shape: Polygon2D = $Shape
@onready var outline: PuzzlePieceOutline = $Outline

var locked := true :
	set(value):
		locked = value
		lock.visible = locked
		play_icon.visible = !locked
		
var default_scale : Vector2
var mouse_hover := false
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
	overlay.polygon = $Shape.polygon
	play_icon.modulate = Color(1,1,1,0)
	update_labels()
	locked = !required_completed_worlds.all(func(world) : return world.world_completed)
	
func update_labels() :
	if levels_text : levels_text.text = str(nb_of_completed_levels) + "/" + str(nb_of_levels)
	if collectibles_text : collectibles_text.text = str(nb_of_collectibles)

func _on_mouse_entered():
	animation_player.play("Preview")
	mouse_hover = true
	play_icon.create_tween().tween_property(play_icon, "modulate", Color(1,1,1,1), 0.2)
	create_tween().tween_property(self, "scale", default_scale * 1.1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	outline.set_type(PuzzlePieceOutline.OutlineType.DRAGGING)
	
func _on_mouse_exited():
	animation_player.stop()
	mouse_hover = false
	play_icon.create_tween().tween_property(play_icon, "modulate", Color(1,1,1,0), 0.2)
	create_tween().tween_property(self, "scale", default_scale * 1.0, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	outline.set_type(PuzzlePieceOutline.OutlineType.NORMAL)

func _on_pressed() -> void:
	if locked : return
	if SubSystemManager.get_scene_manager().load_level_select(world, Vector2(1,0)) :
		SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
		for group in get_tree().get_nodes_in_group("WorldGroup"):
			if !group.is_ancestor_of(self) :
				group.modulate = Color.TRANSPARENT
		for arrow in get_tree().get_nodes_in_group("Arrow"):
			arrow.visible = false
