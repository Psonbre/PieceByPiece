extends Node
class_name SoundManager

@onready var timer: Timer = $Timer

@export var pool_size: int = 4
var audio_pool: Array = []

func _ready() -> void:
	# Initialize the audio pool
	for i in range(pool_size):
		var audio_player = AudioStreamPlayer.new()
		add_child(audio_player)
		audio_pool.append(audio_player)

func get_audio_player() -> AudioStreamPlayer:
	# Find an available AudioStreamPlayer
	for audio_player in audio_pool:
		if not audio_player.playing:
			return audio_player
	return null
	
func play_sound(sound_effect: String, volume_db: float = 0.0, pitch_scale = 1) -> void:
	var audio_player : AudioStreamPlayer = get_audio_player()
	if audio_player == null:
		return
	if sound_effect == "res://Assets/Sounds/walk.ogg":
		if timer.is_stopped():
			# Load the sound stream
			audio_player.stream = load(sound_effect)
			audio_player.volume_db = 20 * (log(SubsystemManager.get_settings_manager().masterVolume * SubsystemManager.get_settings_manager().sfxVolume) / log(10))
			audio_player.pitch_scale = pitch_scale
			audio_player.play()
			# Start the timer
			timer.start()
	else:
		# For other sounds, play them immediately
		audio_player.stream = load(sound_effect)
		audio_player.volume_db = 20 * (log(SubsystemManager.get_settings_manager().masterVolume * SubsystemManager.get_settings_manager().sfxVolume) / log(10))
		audio_player.pitch_scale = pitch_scale
		audio_player.play()
	
