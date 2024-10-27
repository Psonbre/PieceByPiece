extends Node
class_name SettingsManager

var masterVolume: float = 1
var musicVolume: float = 1
var sfxVolume: float = 1

func _update_display_mode(displayMode : DisplayServer.WindowMode):
	DisplayServer.window_set_mode(displayMode)
	
func _update_Vsync_mode(vsyncMode : DisplayServer.VSyncMode):
	DisplayServer.window_set_vsync_mode(vsyncMode)
	
func _update_master_volume(_volume : float):
	masterVolume = _volume
	var index = AudioServer.get_bus_index("Master")
	var volume = 20 * (log(masterVolume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
	
func _update_music_volume(_volume : float):
	musicVolume = _volume
	var index = AudioServer.get_bus_index("Music")
	var volume = 20 * (log(musicVolume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
	
func _update_sfx_volume(_volume : float):
	sfxVolume = _volume
	var index = AudioServer.get_bus_index("SFX")
	var volume = 20 * (log(sfxVolume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
