extends Sprite2D
class_name Background

var transition_time := 1.0

func switch_gradient(gradient: Gradient):
	var current_gradient_texture: GradientTexture1D = material.get_shader_parameter("gradient")
	if not gradient or gradient == current_gradient_texture.gradient: return
	var gradient_speed: float = material.get_shader_parameter("gradient_speed")
	var transition_progress: float = material.get_shader_parameter("transition_progress")
	var time: float = Time.get_ticks_msec() / 1000.0
	var gradient_position: float = fmod(time * gradient_speed, 1.0)
	
	# Sample the current color from the gradient texture
	var current_gradient: Gradient = current_gradient_texture.gradient
	var gradient_color: Color = current_gradient.sample(gradient_position)
	
	# Retrieve the old_color
	var old_color: Color = material.get_shader_parameter("old_color")
	
	# Calculate the effective current color based on transition progress
	var current_color: Color = old_color.lerp(gradient_color, transition_progress)
	
	# Set the old_color to the effective current color
	material.set_shader_parameter("old_color", current_color)
	
	# Update the gradient texture with the new gradient
	var new_gradient_texture := GradientTexture1D.new()
	new_gradient_texture.gradient = gradient
	material.set_shader_parameter("gradient", new_gradient_texture)
	
	# Reset the transition progress
	material.set_shader_parameter("transition_progress", 0)

func _process(delta: float) -> void:
	var transition_progress: float = material.get_shader_parameter("transition_progress")
	if transition_progress != 1.0:
		material.set_shader_parameter("transition_progress", move_toward(transition_progress, 1.0, (1.0 / transition_time) * delta))
