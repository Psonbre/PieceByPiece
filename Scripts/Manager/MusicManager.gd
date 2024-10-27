extends AudioStreamPlayer
class_name MusicManager


func play_music(new_music_name : String) -> void:
	#Load the music stream
	var new_music_stream = load(new_music_name)
	
	#Check if it is not alredy playing
	if (stream != new_music_stream):
		stream = new_music_stream
		play()
		set_Music_volume_db()
		
func stop_music() -> void:
	stop()

func set_Music_volume_db() -> void:
	self.volume_db = 20 * (log(SubsystemManager.get_settings_manager().masterVolume * SubsystemManager.get_settings_manager().musicVolume) / log(10))
	
	
