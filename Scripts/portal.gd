extends Area2D
class_name Portal

var connected_portal : Portal = null

@onready var background = $Background
@onready var foreground = $Foreground
@onready var particles = $Particles
@onready var cooldown = $Cooldown
var puzzle_piece : PuzzlePiece

var activated := false

var pixel_size := 40.0
var target_pixel_size := 40.0
var interval := 1.0
var target_interval := 1.0
var brightness := 2.0
var target_birghtness := 2.0
var entered := false

func _ready() -> void:
	foreground.visible = false

func activate():
	if activated: return
	activated = true
	foreground.visible = true
	pixel_size = 0
	target_pixel_size = 80.0
	target_birghtness = 10.0
	target_interval = 6.0

func deactivate():
	if !activated: return
	activated = false
	foreground.visible = false
	target_pixel_size = 40.0
	target_birghtness = 2.0
	target_interval = 1.0
	connected_portal = null
	
func _process(delta):
	pixel_size = move_toward(pixel_size, target_pixel_size, abs(target_pixel_size - pixel_size) * 2.0 * delta)
	brightness = move_toward(brightness, target_birghtness, abs(target_birghtness - brightness) * 2.0 * delta)
	interval = move_toward(interval, target_interval, abs(target_interval - interval) * 2.0 * delta)
	background.material.set_shader_parameter("pixel_size", pixel_size)
	foreground.material.set_shader_parameter("pixel_size", pixel_size)
	background.material.set_shader_parameter("brightness", brightness)
	background.material.set_shader_parameter("interval", interval)

func _on_body_entered(body):
	if body is Player :
		if activated and !Player.entering_portal and !Player.exiting_portal and !entered:
			body.teleport(self)

func _on_body_exited(body):
	if body is Player and cooldown.is_stopped() :
		entered = false
