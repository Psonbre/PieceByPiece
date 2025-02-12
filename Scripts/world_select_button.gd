extends Button
class_name WorldSelectButton

@onready var play_icon: Polygon2D = $Shape/PlayIcon
@onready var animation_player = $AnimationPlayer
@onready var completed_levels: Label = $DemoPuzzleBox/IncompleteBanner/ProgressIndicatorFrame/CompletedLevels
@onready var number_of_levels: Label = $DemoPuzzleBox/IncompleteBanner/ProgressIndicatorFrame/NumberOfLevels
@onready var collectibles_percentage: Label = $DemoPuzzleBox/IncompleteBanner/GoldPieceBanner/CollectiblesPercentage
@onready var incomplete_banner: Node2D = $DemoPuzzleBox/IncompleteBanner
@onready var completed_banner: Sprite2D = $DemoPuzzleBox/CompletedBanner
@onready var shape: Polygon2D = $Shape
@onready var outline: PuzzlePieceOutline = $Outline
@onready var box_top: Sprite2D = $DemoPuzzleBox/BoxTop

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
	play_icon.modulate = Color(1,1,1,0)
	update_labels()
	
func update_labels() :
	incomplete_banner.visible = nb_of_collectibles < nb_of_levels
	completed_banner.visible = nb_of_collectibles >= nb_of_levels
	if completed_levels : completed_levels.text = str(min(nb_of_completed_levels, nb_of_levels))
	if number_of_levels : number_of_levels.text = str(nb_of_levels)
	if collectibles_percentage : collectibles_percentage.text = str(round((float(nb_of_collectibles) / float(nb_of_levels)) * 100.0)) + "%"

func _on_mouse_entered():
	animation_player.play("Preview")
	mouse_hover = true
	play_icon.create_tween().tween_property(play_icon, "modulate", Color(1,1,1,1), 0.2)
	create_tween().tween_property(self, "scale", default_scale * 1.1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(box_top, "modulate:a", 0, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	outline.set_type(PuzzlePieceOutline.OutlineType.HIGHLIGHT)
	
func _on_mouse_exited():
	animation_player.stop()
	mouse_hover = false
	play_icon.create_tween().tween_property(play_icon, "modulate", Color(1,1,1,0), 0.2)
	create_tween().tween_property(self, "scale", default_scale * 1.0, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	create_tween().tween_property(box_top, "modulate:a", 1, 1).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	outline.set_type(PuzzlePieceOutline.OutlineType.NORMAL)

func _on_pressed() -> void:
	if !SubSystemManager.get_scene_manager().current_screen.is_ancestor_of(self) : return
	if SubSystemManager.get_scene_manager().load_level_select(world, Vector2(0,1)) :
		SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
		for group in get_tree().get_nodes_in_group("WorldGroup"):
			if !group.is_ancestor_of(self) :
				group.modulate = Color.TRANSPARENT
		for arrow in get_tree().get_nodes_in_group("Arrow"):
			arrow.visible = false
