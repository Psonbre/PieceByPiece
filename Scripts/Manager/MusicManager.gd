extends AudioStreamPlayer
class_name MusicManager

func play_music(new_music_name : String) -> void:
	#Load the music stream
	var new_music_stream = load(new_music_name)
	
	#Check if it is not alredy playing
	if (stream != new_music_stream):
		stream = new_music_stream
		play()
		
func stop_music() -> void:
	stop()

func set_Music_volume_db(volume: float) -> void:
	self.volume_db = volume
	
	
