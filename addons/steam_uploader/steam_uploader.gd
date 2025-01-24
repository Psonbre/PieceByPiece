@tool
extends EditorPlugin

var dock := preload("res://addons/steam_uploader/dock.tscn").instantiate()
const SETTINGS_PATH_PREFIX = "SteamUploader/presets/"

func _enter_tree() -> void:
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)
	load_inputs()

func _exit_tree() -> void:
	remove_control_from_docks(dock)
	save_inputs()

func load_inputs():
	var settings = EditorInterface.get_editor_settings()
	for child in dock.find_children("*"):
		if child is LineEdit: 
			var setting_path = SETTINGS_PATH_PREFIX + child.name
			if settings.has_setting(setting_path):
				child.text = settings.get_setting(setting_path)
		if child is SpinBox: 
			var setting_path = SETTINGS_PATH_PREFIX + child.name
			if settings.has_setting(setting_path):
				child.value = settings.get_setting(setting_path)
		elif child is OptionButton: 
			var setting_path = SETTINGS_PATH_PREFIX + child.name
			if settings.has_setting(setting_path):
				child.selected = settings.get_setting(setting_path)
	
func save_inputs():
	var settings = EditorInterface.get_editor_settings()
	for child in dock.find_children("*"):
		var setting_path = SETTINGS_PATH_PREFIX + child.name
		StreamPeerBuffer
		if child is LineEdit: 
			settings.set_setting(setting_path, child.text)
			if child.secret :
				settings.add_property_info({
					"name": setting_path,
					"type": "string",
					"usage" : PROPERTY_USAGE_NO_EDITOR,
				})
				
		if child is SpinBox: 
			settings.set_setting(setting_path, child.value)
		elif child is OptionButton:
			settings.set_setting(setting_path, child.selected)
