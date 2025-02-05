extends Polygon2D

@onready var god_rays: Polygon2D = $"../GodRays"

@export var gradient : GradientTexture1D
@export var time := 0.0 :
	set(value) :
		var delta := value - time
		god_rays.polygon[3].x -= delta * 2560.0 * 2.0
		god_rays.polygon[2].x -= delta * 2560.0 * 2.0
		god_rays.polygon[7].x -= delta * 2560.0 * 2.0
		god_rays.polygon[4].x -= delta * 2560.0 * 2.0
		time = value
		god_rays.modulate.a = pingpong(-time, 1)
		color = gradient.gradient.sample(pingpong(time, 1))
