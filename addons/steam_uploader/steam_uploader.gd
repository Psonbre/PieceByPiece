@tool
extends EditorPlugin

var dock := preload("res://addons/steam_uploader/dock.tscn").instantiate()

func _enter_tree() -> void:
	add_control_to_dock(EditorPlugin.DOCK_SLOT_RIGHT_BL, dock)
	dock.button.connect("pressed", func() : build_project())

func _exit_tree() -> void:
	remove_control_from_docks(dock)

func build_project():
	# Get the path to the current Godot executable
	var godot_executable = OS.get_executable_path()

	# Construct the command line arguments
	var args = [
		godot_executable,
		"--no-window",
		"--export-release", dock.build_preset, dock.build_path
	]

	var output = []
	var result = OS.execute(godot_executable, args, output)
	if result == OK:
		print("Build process started successfully.")
	else:
		print(output)
