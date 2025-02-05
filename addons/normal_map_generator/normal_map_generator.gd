@tool
extends EditorPlugin

const strength := 1.0

func _enter_tree():
	# Find FileSystem dock
	var popups := get_editor_interface().get_file_system_dock().find_children("*", "PopupMenu", true, false)
	for popup : PopupMenu in popups :
		popup.about_to_popup.connect(add_custom_option.bind(popup))
	
func _exit_tree():
	var popups := get_editor_interface().get_file_system_dock().find_children("*", "PopupMenu", true, false)
	for popup : PopupMenu in popups :
		if popup.id_pressed.is_connected(id_pressed) :
			popup.id_pressed.disconnect(id_pressed)

func add_custom_option(popup : PopupMenu):
	var selected_files := get_editor_interface().get_selected_paths()
	if selected_files.size() > 0:
		var all_compatible = true
		for resource_path in selected_files:
			if not (ResourceLoader.exists(resource_path) and ResourceLoader.load(resource_path, "", ResourceLoader.CACHE_MODE_IGNORE) is Texture2D):
				all_compatible = false
				break

		if all_compatible:
			popup.add_separator()
			popup.add_item("Generate canvas texture", 1001)
			if not popup.id_pressed.is_connected(id_pressed):
				popup.id_pressed.connect(id_pressed)

func id_pressed(id: int):
	if id == 1001:
		var selected_files := get_editor_interface().get_selected_paths()
		for resource_path in selected_files:
			var resource = load(resource_path)
			if resource is Texture2D:
				generate_canvas_texture(resource)

func generate_canvas_texture(texture : Texture2D):
	var image = texture.get_image()
	var width = image.get_width()
	var height = image.get_height()
	var normal_image := Image.create(width, height, false, Image.FORMAT_RGBA8)

	for y in range(height):
		for x in range(width):
			var x_left   = clamp(x - 1, 0, width - 1)
			var x_right  = clamp(x + 1, 0, width - 1)
			var y_top    = clamp(y - 1, 0, height - 1)
			var y_bottom = clamp(y + 1, 0, height - 1)
			
			var col_left   = image.get_pixel(x_left, y)
			var col_right  = image.get_pixel(x_right, y)
			var col_top    = image.get_pixel(x, y_top)
			var col_bottom = image.get_pixel(x, y_bottom)
			
			var brightness_left   = col_left.r * 0.299 + col_left.g * 0.587 + col_left.b * 0.114
			var brightness_right  = col_right.r * 0.299 + col_right.g * 0.587 + col_right.b * 0.114
			var brightness_top    = col_top.r * 0.299 + col_top.g * 0.587 + col_top.b * 0.114
			var brightness_bottom = col_bottom.r * 0.299 + col_bottom.g * 0.587 + col_bottom.b * 0.114
			
			var dX = (brightness_right - brightness_left) * strength
			var dY = (brightness_bottom - brightness_top) * strength
			
			var normal = Vector3(-dX, dY, 1.0)
			var r = normal.x * 0.5 + 0.5
			var g = normal.y * 0.5 + 0.5
			var b = normal.z * 0.5 + 0.5
			var a = image.get_pixel(x, y).a
			
			normal_image.set_pixel(x, y, Color(r, g, b, a))

	# Save images as PNG
	var orig_path := texture.resource_path
	var base_dir := orig_path.get_base_dir()
	var file_name := orig_path.get_file()
	var dot_index := file_name.rfind(".")
	var base_name := file_name.substr(0, dot_index) if dot_index != -1 else file_name
	if !base_name.to_lower().ends_with("_diffuse") : base_name += "_Diffuse"
	
	var diffuse_texture_path = base_dir + "/" + base_name + ".png"
	var normal_texture_path = base_dir + "/" + base_name.replace("_Diffuse", "_NormalMap") + ".png"
	var canvas_texture_path = base_dir + "/" + base_name.replace("_Diffuse", "_CanvasTexture") + ".tres"

	DirAccess.remove_absolute(ProjectSettings.globalize_path(texture.resource_path))
	image.save_png(diffuse_texture_path)
	normal_image.save_png(normal_texture_path)
	
	# Load or create CanvasTexture
	var canvas_texture: CanvasTexture
	if FileAccess.file_exists(canvas_texture_path):
		canvas_texture = load(canvas_texture_path) as CanvasTexture
		if not canvas_texture:
			canvas_texture = CanvasTexture.new()
	else:
		canvas_texture = CanvasTexture.new()

	# Update the CanvasTexture properties
	canvas_texture.diffuse_texture = load(diffuse_texture_path)
	canvas_texture.normal_texture = load(normal_texture_path)

	# Save updated CanvasTexture
	ResourceSaver.save(canvas_texture, canvas_texture_path)
	get_editor_interface().get_resource_filesystem().scan_sources()
