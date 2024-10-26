extends Control

@onready var vsyncSlider = $"Names/V-Sync/HSplitContainer/VsyncSlider"
@onready var resolutionSlider = $Names/Resolution/HSplitContainer/ResolutionSlider
@onready var displaySlider = $Names/DisplayMode/HSplitContainer/DisplaySlider


var resolutionsPossible: Dictionary = {}
var displayModePossible: Dictionary = {
		'Windowed' : DisplayServer.WINDOW_MODE_MAXIMIZED,
		'Fullscreen' : DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		}
var vsyncModePossible: Dictionary = {
		'Disabled' : [DisplayServer.VSYNC_DISABLED,""],
		'Enabled' : [DisplayServer.VSYNC_ENABLED,""],
		'Adaptive' : [DisplayServer.VSYNC_ADAPTIVE, "Activate Vsync ONLY when the framerate is over the refresh rate of the display"]
		}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	addDisplays()
	addVsyncs()

func addDisplays():
	for displayPossible in displayModePossible:
		displaySlider.add_item(displayPossible, displayModePossible[displayPossible])

func addVsyncs():
	for vsyncMode in vsyncModePossible:
		var vsync_data = vsyncModePossible[vsyncMode]
		var value = vsync_data[0]
		var hint = vsync_data[1]
		vsyncSlider.add_item(vsyncMode, value)
		
		var index = vsyncSlider.get_item_count() - 1
		vsyncSlider.set_item_tooltip(index,hint)


func _on_display_slider_item_selected(index: int) -> void:
	var itemText = displaySlider.get_item_text(index)
	var displayMode = displayModePossible[itemText]
	SubsystemManager.get_settings_manager()._update_display_mode(displayMode)


func _on_vsync_slider_item_selected(index: int) -> void:
	var itemText = vsyncSlider.get_item_text(index)
	var vsyncmode = vsyncModePossible[itemText]
	SubsystemManager.get_settings_manager()._update_Vsync_mode(vsyncmode[0])
