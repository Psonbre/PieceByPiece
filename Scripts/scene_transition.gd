xtends CanvasLayer

@onready var animationPlayer = $AnimationPlayer
@onready var colorRect = $ColorRect

func fade_in():
	colorRect.visible = true
	animationPlayer.play("fade_in")

func fade_out():
	animationPlayer.play("fade_out")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_in":
		emit_signal("transitioned")
	if anim_name == "fade_out":
		colorRect.visible = false
