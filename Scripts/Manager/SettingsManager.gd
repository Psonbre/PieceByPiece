extends Node
class_name SettingsManager

var masterVolume: float = 1
var musicVolume: float = 1
var sfxVolume: float = 1
var gamepad_sensitivity : float = 80
var fpsEnabled : bool = false
var speedrunEnabled : bool = false

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
	
func _get_current_language():
	return TranslationServer.get_locale()
	
func _update_language(language : String):
	TranslationServer.set_locale(language)
	SubSystemManager.get_config_file_manager()._save_language(language)
	
func _update_gamepad_sensitivity(sensitivity : float):
	gamepad_sensitivity = sensitivity
	SubSystemManager.get_config_file_manager()._save_gamepad_sensitivity(sensitivity)
	
func _update_fps_counter(enabled : bool):
	fpsEnabled = enabled
	SubSystemManager.get_hud_manager()._toggle_fps_counter(enabled)
	SubSystemManager.get_config_file_manager()._save_fps_counter(enabled)
	
func _update_speedrun_counter(enabled : bool):
	speedrunEnabled = enabled
	SubSystemManager.get_hud_manager()._toggle_speedrun_counter(enabled)
	SubSystemManager.get_config_file_manager()._save_speedrun_counter(enabled)
	
func _update_master_volume(_volume : float):
	masterVolume = _volume
	var index = AudioServer.get_bus_index("Master")
	var volume = 20 * (log(_volume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
	SubSystemManager.get_config_file_manager()._save_master_volume(_volume)
	
func _update_music_volume(_volume : float):
	musicVolume = _volume
	var index = AudioServer.get_bus_index("Music")
	var volume = 20 * (log(_volume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
	SubSystemManager.get_config_file_manager()._save_music_volume(_volume)
	
func _update_sfx_volume(_volume : float):
	sfxVolume = _volume
	var index = AudioServer.get_bus_index("SFX")
	var volume = 20 * (log(_volume) / log(10))
	AudioServer.set_bus_volume_db(index,volume)
	SubSystemManager.get_config_file_manager()._save_sfx_volume(_volume)
