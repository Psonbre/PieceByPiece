extends Camera2D

var max_zoom := 2.0
var min_zoom := 1.0
var pan_tween : Tween
var target_position := Vector2.ZERO
var target_zoom := Vector2.ONE

func pan(new_position := Vector2.ZERO, new_zoom := Vector2.ONE) :
	if new_zoom.x < min_zoom : new_zoom = Vector2.ONE * min_zoom
	elif new_zoom.x > max_zoom : new_zoom = Vector2.ONE * max_zoom
	
	target_position = new_position
	target_zoom = new_zoom
	pan_tween = create_tween()
	pan_tween.tween_property(self, "global_position", new_position, 4.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	pan_tween.parallel().tween_property(self, "zoom", new_zoom, 4.0).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
