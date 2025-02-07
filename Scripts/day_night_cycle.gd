extends Polygon2D


const day_lenght := 60 * 5

@onready var god_rays: Polygon2D = $"../GodRays"
@export var gradient : GradientTexture1D
@export var god_rays_gradient : GradientTexture1D
@export var time := 0.0 :
	set(value) :
		var delta := value - time
		time = value
		color = gradient.gradient.sample(pingpong(time, 1))
		god_rays.color = god_rays_gradient.gradient.sample(pingpong(time, 1))

func _process(delta: float) -> void:
	time += delta / day_lenght
