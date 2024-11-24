extends AudioStreamPlayer
class_name MusicManager

func play_music(new_music_stream : AudioStream) -> void:
	if (stream != new_music_stream):
		stream = new_music_stream
		play()
		
func stop_music() -> void:
	stop()

func set_Music_volume_db(volume: float) -> void:
	self.volume_db = volume
