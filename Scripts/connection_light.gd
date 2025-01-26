extends Rift
class_name ConnectionLight
@onready var light: PointLight2D = $LightParent/Light

func _ready() -> void:
	create_tween().tween_property(light, "energy", 0, 0.5)
	await create_tween().tween_property(self, "modulate:a", 0, 0.5).finished
