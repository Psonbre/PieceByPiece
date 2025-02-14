extends TabContainer

@onready var vsyncSlider = $"VIDEO/VIDEO/Items/V-Sync/HSplitContainer/VsyncSlider"
@onready var fullscreenCheckbox : CheckButton = $VIDEO/VIDEO/Items/Fullscreen/HSplitContainer/FullscreenCheckBox
@onready var masterSlider = $AUDIO/AUDIO/Items/Master/HSplitContainer/MasterSlider
@onready var musicSlider = $AUDIO/AUDIO/Items/Music/HSplitContainer/MusicSlider
@onready var sfxSlider = $AUDIO/AUDIO/Items/SFX/HSplitContainer/SFXSlider
@onready var languagesSlider = $GENERAL/GENERAL/Items/LanguagesMode/HSplitContainer/LanguagesSlider
@onready var gamepadSens = $CONTROLS/CONTROLS/Items/GamepadSensitivity/HSplitContainer/GamepadSensSlider
@onready var fpsCheckbox = $GENERAL/GENERAL/Items/FpsCounter/HSplitContainer/FPSCheckbox
@onready var speedrunCheckbox = $GENERAL/GENERAL/Items/SpeedrunCounter/HSplitContainer/SpeedrunCheckbox

@export var popupItemFontSize = 32
var can_exit := true

const flagsPath : String  = "res://Assets/Languages/"

var vsyncModePossible: Dictionary = {
		'DISABLED' : [DisplayServer.VSYNC_DISABLED,""],
		'ENABLED' : [DisplayServer.VSYNC_ENABLED,""],
		'ADAPTIVE' : [DisplayServer.VSYNC_ADAPTIVE, "ADAPTIVE_TOOLTIP"]
		}
		
var languagesPossible: Dictionary = {
	'English' : ['en', flagsPath + "english.png"],
	'Québecois' : ['fr_CA', flagsPath + "quebec.png"],
	'Français' : ['fr', flagsPath + "french.png"],
	'Español' : ['es', flagsPath + "spain.png"],
	'Italiano' : ['it', flagsPath + "italy.png"],
	'Português' : ['pt', flagsPath + "portugal.png"],
	'Deutsch' : ['de', flagsPath + "germany.png"],
	'Русский' : ['ru', flagsPath + "russian.png"],
	'한국어' : ['ko', flagsPath + "south_korea.png"],
	'日本語' : ['ja', flagsPath + "japan.png"],
	'हिन्दी' : ['hi', flagsPath + "india.png"],
	'简体中文' : ['cmn_Hans', flagsPath + "china.png"],
	'繁體中文' : ['cmn_Hant', flagsPath + "china.png"]
}

signal update_first_input(input : Control)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("LeftTab"):
		var newTab : int = current_tab - 1
		if newTab >= 0 : 
			current_tab = newTab
	if Input.is_action_just_pressed("RightTab"):
		var newTab : int = current_tab + 1
		if newTab < get_tab_count() : 
			current_tab = newTab

############Set Focus for Gamepad when switching tabs#####################		
func update_focus():
	var current_container = get_child(current_tab)  # Get the active tab container
	if not current_container:
		return  # Safety check

	var first_focusable : Control = find_focusable(current_container)
	if first_focusable:
		emit_signal("update_first_input", first_focusable)

func find_focusable(node: Node) -> Control:
	for child in node.get_children():
		if child is BaseButton or child is Range:
			return child  # Return the first found focusable node
		var focusable_child = find_focusable(child)  # Recursively check deeper levels
		if focusable_child:
			return focusable_child
	return null  # Return null if no focusable node is found
	
func _on_tab_changed(tab: int) -> void:
	update_focus()
	
##############################################################################
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_tree().current_scene == get_parent().get_parent() :
		SubSystemManager.get_scene_manager().load_settings_menu.call_deferred(Vector2.ZERO)
		get_parent().get_parent().queue_free()
		return
	
	_update_fullscreen_mode()
	addVsyncs()
	addLanguages()
	update_volume_sliders()
	update_sensitivities()
	update_gameplay_checkboxes()
	
#Languages------------------------
func addLanguages():
	var currentId : int = 0
	for language in languagesPossible:
		var language_data = languagesPossible[language]
		var value = language_data[0]
		var flag = language_data[1]
		language_data.append(currentId)
		
		languagesSlider.add_item(language, currentId)
		
		languagesSlider.set_item_icon(currentId, load(flag))
		
		currentId += 1
		
	languagesSlider.get_popup().add_theme_font_size_override("font_size",popupItemFontSize)
	
	_select_language()
	
func _select_language():
	var currentLanguage = SubSystemManager.get_settings_manager()._get_current_language()
	# Iterate through the items in the OptionButton
	for language_name in languagesPossible.keys():
		if languagesPossible[language_name][0] == currentLanguage:  # Match the string (e.g., 'fr')
			var target_id = languagesPossible[language_name][2]  # Get the corresponding ID
			# Select the item in the OptionButton
			languagesSlider.select(target_id)
			return
	
#Fullscreen------------------------
func _update_fullscreen_mode():
	var fullscreen = SubSystemManager.get_settings_manager()._get_display_mode()
	
	if (fullscreen == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN):
		fullscreenCheckbox.button_pressed = true
	else:
		fullscreenCheckbox.button_pressed = false


#VSync------------------------			
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

#Audio----------------------		
func update_volume_sliders():
	masterSlider.value = SubSystemManager.get_settings_manager().masterVolume
	musicSlider.value = SubSystemManager.get_settings_manager().musicVolume
	sfxSlider.value = SubSystemManager.get_settings_manager().sfxVolume
	
func update_sensitivities():
	gamepadSens.value = SubSystemManager.get_settings_manager().gamepad_sensitivity
	
func update_gameplay_checkboxes():
	fpsCheckbox.button_pressed = SubSystemManager.get_settings_manager().fpsEnabled
	speedrunCheckbox.button_pressed = SubSystemManager.get_settings_manager().speedrunEnabled

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


func _on_languages_slider_item_selected(index: int) -> void:
	var itemText = languagesSlider.get_item_text(index)
	var language = languagesPossible[itemText]
	SubSystemManager.get_settings_manager()._update_language(language[0])


func _on_fullscreen_check_box_toggled(toggled_on: bool) -> void:
	if (toggled_on):
		SubSystemManager.get_settings_manager()._update_display_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		SubSystemManager.get_settings_manager()._update_display_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_gamepad_sens_slider_value_changed(value: float) -> void:
	SubSystemManager.get_settings_manager()._update_gamepad_sensitivity(value)


func _on_fps_checkbox_toggled(toggled_on: bool) -> void:
	SubSystemManager.get_settings_manager()._update_fps_counter(toggled_on)

func _on_speedrun_checkbox_toggled(toggled_on: bool) -> void:
	SubSystemManager.get_settings_manager()._update_speedrun_counter(toggled_on)
