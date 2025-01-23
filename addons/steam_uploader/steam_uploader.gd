@tool
extends EditorPlugin

var dock := preload("res://addons/steam_uploader/dock.tscn").instantiate()
const SETTINGS_PATH_PREFIX = "SteamUploader/presets/"

func _enter_tree() -> void:
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)
	dock.get_node("Build/Build").connect("pressed", func(): build_project())
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
	dock._on_build_path_changed("")
	
func save_inputs():
	var settings = EditorInterface.get_editor_settings()
	for child in dock.find_children("*"):
		var setting_path = SETTINGS_PATH_PREFIX + child.name
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
	
func build_project():
	# Validate inputs dynamically
	for child in dock.find_children("*"):
		if child is LineEdit and child.text.is_empty():
			push_error(child.name + " must not be empty")
			return
	# Get the path to the current Godot executable
	var godot_executable = OS.get_executable_path()

	# Construct the command line arguments
	var args = [
		"--headless",
		"--export-release",
		dock.get_value("Build Preset"), 
		str(dock.get_value("Build Path")) + "\\" + str(dock.get_value("File Name")),
		"--quit"
	]

	var output = []
	var result = OS.execute(godot_executable, args, output)
	dock.get_node("ConfirmationDialog").popup_centered()
