extends Node
class_name SettingsManager

func _update_display_mode(displayMode : DisplayServer.WindowMode):
	DisplayServer.window_set_mode(displayMode)
	
func _update_Vsync_mode(vsyncMode : DisplayServer.VSyncMode):
	DisplayServer.window_set_vsync_mode(vsyncMode)
