extends Control

@onready var vsyncSlider = $"Display/V-Sync/HSplitContainer/VsyncSlider"
@onready var displaySlider = $Display/DisplayMode/HSplitContainer/DisplaySlider
@onready var masterSlider = $Sounds/Master/HSplitContainer/MasterSlider
@onready var musicSlider = $Sounds/HBoxContainer2/HSplitContainer/MusicSlider
@onready var sfxSlider = $Sounds/HBoxContainer3/HSplitContainer/SFXSlider

@export var popupItemFontSize = 32
var can_exit := true

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
	if get_tree().current_scene == get_parent().get_parent() :
		SubSystemManager.get_scene_manager().load_settings_menu.call_deferred(Vector2.ZERO)
		get_parent().get_parent().queue_free()
		return
	addDisplays()
	addVsyncs()
	update_volume_sliders()

func addDisplays():
	for displayPossible in displayModePossible:
		displaySlider.add_item(displayPossible, displayModePossible[displayPossible])
		
	displaySlider.get_popup().add_theme_font_size_override("font_size",popupItemFontSize)
	
	_select_display_mode()
	
func _select_display_mode():
	var currentDisplay = SubSystemManager.get_settings_manager()._get_display_mode()
	# Iterate through the items in the OptionButton
	for i in range(displaySlider.item_count):
		if displaySlider.get_item_id(i) == currentDisplay:
			displaySlider.select(i)
			return
			
func addVsyncs():
	for vsyncMode in vsyncModePossible:
		var vsync_data = vsyncModePossible[vsyncMode]
		var value = vsync_data[0]
		var hint = vsync_data[1]
		vsyncSlider.add_item(vsyncMode, value)
		
		var index = vsyncSlider.get_item_count() - 1
		vsyncSlider.set_item_tooltip(index,hint)
		vsyncSlider.get_item_tooltip(index)
	
	vsyncSlider.get_popup().add_theme_font_size_override("font_size",popupItemFontSize)
	
	_select_vsync_mode()
	
func _select_vsync_mode():
	var currentVsync = SubSystemManager.get_settings_manager()._get_vsync_mode()
	# Iterate through the items in the OptionButton
	for i in range(vsyncSlider.item_count):
		if vsyncSlider.get_item_id(i) == currentVsync:
			vsyncSlider.select(i)
			return
		
func update_volume_sliders():
	masterSlider.value = SubSystemManager.get_settings_manager().masterVolume
	musicSlider.value = SubSystemManager.get_settings_manager().musicVolume
	sfxSlider.value = SubSystemManager.get_settings_manager().sfxVolume


func _on_display_slider_item_selected(index: int) -> void:
	var itemText = displaySlider.get_item_text(index)
	var displayMode = displayModePossible[itemText]
	SubSystemManager.get_settings_manager()._update_display_mode(displayMode)


func _on_vsync_slider_item_selected(index: int) -> void:
	var itemText = vsyncSlider.get_item_text(index)
	var vsyncmode = vsyncModePossible[itemText]
	SubSystemManager.get_settings_manager()._update_Vsync_mode(vsyncmode[0])	

func _on_master_slider_value_changed(value: float) -> void:
	SubSystemManager.get_settings_manager()._update_master_volume(value)


func _on_music_slider_value_changed(value: float) -> void:
	SubSystemManager.get_settings_manager()._update_music_volume(value)


func _on_sfx_slider_value_changed(value: float) -> void:
	SubSystemManager.get_settings_manager()._update_sfx_volume(value)


func _on_sfx_slider_drag_ended(_value_changed: bool) -> void:
	SubSystemManager.get_sound_manager().play_sound(preload("res://Assets/Sounds/button_click.ogg"), -8, 1)
