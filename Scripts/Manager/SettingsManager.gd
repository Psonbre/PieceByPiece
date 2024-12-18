extends Node
class_name SettingsManager

var masterVolume: float = 1
var musicVolume: float = 1
var sfxVolume: float = 1

func _get_display_mode():
	return DisplayServer.window_get_mode()

func _update_display_mode(displayMode : DisplayServer.WindowMode):
	DisplayServer.window_set_mode(displayMode)
	SubSystemManager.get_config_file_manager()._save_fullscreen_mode(displayMode)
	
func _get_vsync_mode():
	return DisplayServer.window_get_vsync_mode()
	
func _update_Vsync_mode(vsyncMode : DisplayServer.VSyncMode):
	DisplayServer.window_set_vsync_mode(vsyncMode)
	SubSystemManager.get_config_file_manager()._save_vsync_mode(vsyncMode)
	
func _update_master_volume(_volume : float):
	masterVolume = _volume
	var index = AudioServer.get_bus_index("Master")
	var volume = 20 * (log(masterVolume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
	SubSystemManager.get_config_file_manager()._save_master_volume(_volume)
	
func _update_music_volume(_volume : float):
	musicVolume = _volume
	var index = AudioServer.get_bus_index("Music")
	var volume = 20 * (log(musicVolume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
	SubSystemManager.get_config_file_manager()._save_music_volume(_volume)
	
func _update_sfx_volume(_volume : float):
	sfxVolume = _volume
	var index = AudioServer.get_bus_index("SFX")
	var volume = 20 * (log(sfxVolume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
	SubSystemManager.get_config_file_manager()._save_sfx_volume(_volume)
