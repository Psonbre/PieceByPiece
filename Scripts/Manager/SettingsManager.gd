extends Node
class_name SettingsManager

var masterVolume: float = 1
var musicVolume: float = 1
var sfxVolume: float = 1

func _update_display_mode(displayMode : DisplayServer.WindowMode):
	DisplayServer.window_set_mode(displayMode)
	
func _update_Vsync_mode(vsyncMode : DisplayServer.VSyncMode):
	DisplayServer.window_set_vsync_mode(vsyncMode)
	
func _update_master_volume(volume : float):
	masterVolume = volume
	SubsystemManager.get_music_manager().set_Music_volume_db()
	
func _update_music_volume(volume : float):
	musicVolume = volume
	SubsystemManager.get_music_manager().set_Music_volume_db()
	
func _update_sfx_volume(volume : float):
	sfxVolume = volume
