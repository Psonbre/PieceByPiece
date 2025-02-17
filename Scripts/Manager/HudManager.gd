extends CanvasLayer
class_name HudManager

@onready var fpsLabel = $FPSCounter
@onready var speedrunLabel = $SpeedrunCounter

var timeElapsed : float
var speedrunCounterRunning : bool = false

func _toggle_fps_counter(toggle : bool):
	if (fpsLabel):
		fpsLabel.visible = toggle
	else:
		await SubSystemManager.instance.process_frame
		_toggle_fps_counter(toggle)
	
func _toggle_speedrun_counter(toggle : bool):
	if (speedrunLabel):
		speedrunLabel.visible = toggle
		_clear_speedrun_counter()
	else:
		await SubSystemManager.instance.process_frame
		_toggle_speedrun_counter(toggle)
	
func _start_speedrun_counter():
	speedrunCounterRunning = true
	
func _stop_speedrun_counter():
	speedrunCounterRunning = false
	
func _clear_speedrun_counter():
	timeElapsed = 0
	update_speedrun_label()

func _process(delta: float) -> void:
	update_fps_label()
	if (speedrunCounterRunning && speedrunLabel.visible):
		timeElapsed += delta
		update_speedrun_label()
		
func update_fps_label():
	if (fpsLabel.visible):
		fpsLabel.text = str(Engine.get_frames_per_second())
		
func update_speedrun_label():
	var total_seconds: int = int(timeElapsed)
	var hours: int = floor(total_seconds / 3600.0)
	var minutes: int = floor((total_seconds % 3600) / 60.0)
	var seconds: int = total_seconds % 60
	var milliseconds: int = int((timeElapsed - total_seconds) * 100)
	
	var hours_part = "" if hours == 0 else str(hours) + ":"
	
	var formatted_time = "{0}{1}:{2}.{3}".format([
		hours_part,
		str(minutes).pad_zeros(2),
		str(seconds).pad_zeros(2),
		str(milliseconds).pad_zeros(2)
	])
	
	speedrunLabel.text = formatted_time
		
