extends FloatingUI

func _ready() -> void:
	super._ready()
	modulate.a = 0
	
func show_title():
	return create_tween().tween_property(self, "modulate:a", 1, 0.3)
	
func hide_title():
	return create_tween().tween_property(self, "modulate:a", 0, 0.3)
