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
	for audio_player in audio_pool:
		if not audio_player.playing:
			return audio_player
			
	var audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_pool.append(audio_player)
	return audio_player
	
func play_sound(sound_effect: String, volume_db: float = 0.0, pitch_scale = 1) -> void:
	var audio_player := get_audio_player()
	audio_player.stream = load(sound_effect)
	audio_player.volume_db = volume_db
	audio_player.pitch_scale = pitch_scale
	audio_player.play()
	
