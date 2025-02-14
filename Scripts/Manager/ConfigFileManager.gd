extends Node
class_name ConfigFileManager

var configFile = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

const VIDEO = "video"
const FULLSCREEN = "fullscreenMode"
const VSYNC = "vsyncMode"

const AUDIO = "audio"
const MASTER_VOLUME = "masterVolume"
const MUSIC_VOLUME = "musicVolume"
const SFX_VOLUME = "sfxVolume"

const GENERAL = "general"
const LANGUAGE = "language"

const CONTROLS = "controls"
const GP_SENS = "gamepadSensitivity"

const DEFAULT_FULLSCREEN = DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
const DEFAULT_VSYNC = DisplayServer.VSYNC_ENABLED

const DEFAULT_MASTER_VOLUME = 1
const DEFAULT_MUSIC_VOLUME = 1
const DEFAULT_SFX_VOLUME = 1

const DEFAULT_LANGUAGE = 'en'

const DEFAULT_GP_SENS = 80

var config_template = {
	GENERAL: {
		LANGUAGE: DEFAULT_LANGUAGE
	},
	CONTROLS: {
		GP_SENS: DEFAULT_GP_SENS
	},
	VIDEO: {
		FULLSCREEN: DEFAULT_FULLSCREEN,
		VSYNC: DEFAULT_VSYNC
	},
	AUDIO: {
		MASTER_VOLUME: DEFAULT_MASTER_VOLUME,
		MUSIC_VOLUME: DEFAULT_MUSIC_VOLUME,
		SFX_VOLUME: DEFAULT_SFX_VOLUME
	}
}

func _load_config():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		_init_config()
	else:
		configFile.load(SETTINGS_FILE_PATH)
		_verify_config()
	_apply_config()
		
#Apply config values to the game
func _apply_config():
	var settings = SubSystemManager.get_settings_manager()

	settings._update_language(configFile.get_value(GENERAL,LANGUAGE))
	
	settings._update_gamepad_sensitivity(configFile.get_value(CONTROLS, GP_SENS))

	settings._update_display_mode(configFile.get_value(VIDEO,FULLSCREEN))
	settings._update_Vsync_mode(configFile.get_value(VIDEO,VSYNC))
	
	settings._update_master_volume(configFile.get_value(AUDIO,MASTER_VOLUME))
	settings._update_music_volume(configFile.get_value(AUDIO,MUSIC_VOLUME))
	settings._update_sfx_volume(configFile.get_value(AUDIO,SFX_VOLUME))
		
#Create the config file at first launch
func _init_config():
	for section in config_template.keys():
		for key in config_template[section].keys():
			configFile.set_value(section, key, config_template[section][key])
		
	configFile.save(SETTINGS_FILE_PATH)
		
#Check if the config template is correct
func _verify_config():
	var is_config_updated = false

	for section in config_template.keys():
		for key in config_template[section].keys():
			if !configFile.has_section_key(section, key):
				print("Adding missing key: ", section, "/", key)
				configFile.set_value(section, key, config_template[section][key])
				is_config_updated = true

	if is_config_updated:
		configFile.save(SETTINGS_FILE_PATH)
		print("Config file updated with missing values.")
		
func _save_language(language : String):
	configFile.set_value(GENERAL,LANGUAGE, language)
	configFile.save(SETTINGS_FILE_PATH)
	
func _save_gamepad_sensitivity(sensitivity: float):
	configFile.set_value(CONTROLS,GP_SENS, sensitivity)
	configFile.save(SETTINGS_FILE_PATH)
		
func _save_fullscreen_mode(fullscreenMode : DisplayServer.WindowMode):
	configFile.set_value(VIDEO,FULLSCREEN, fullscreenMode)
	configFile.save(SETTINGS_FILE_PATH)
	
func _save_vsync_mode(vsyncMode : DisplayServer.VSyncMode):
	configFile.set_value(VIDEO,VSYNC, vsyncMode)
	configFile.save(SETTINGS_FILE_PATH)

func _save_master_volume(volume : float):
	configFile.set_value(AUDIO,MASTER_VOLUME, volume)
	configFile.save(SETTINGS_FILE_PATH)
	
func _save_music_volume(volume : float):
	configFile.set_value(AUDIO,MUSIC_VOLUME, volume)
	configFile.save(SETTINGS_FILE_PATH)

func _save_sfx_volume(volume : float):
	configFile.set_value(AUDIO,SFX_VOLUME, volume)
	configFile.save(SETTINGS_FILE_PATH)
