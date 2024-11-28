class_name SaveManager

static var world_data: Dictionary = {}

static func _save_to_file():
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_file.store_string(JSON.new().stringify(world_data))
	save_file.close()

static func _load_from_file():
	if FileAccess.file_exists("user://savegame.save"):
		var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
		var json_parser = JSON.new()
		var parse_result = json_parser.parse(save_file.get_as_text())
		if parse_result == OK:
			var loaded_data = json_parser.get_data()
			# Convert string keys back to enums
			for key in loaded_data.keys():
				var enum_key = SceneManager.WORLDS.get(int(key))
				world_data[enum_key] = loaded_data[key]
		save_file.close()

static func save_level_as_completed(world: SceneManager.WORLDS, level: String):
	if not world_data.has(world):
		world_data[world] = {"completed_levels": [], "collectible_levels": []}
	if level not in world_data[world]["completed_levels"]:
		world_data[world]["completed_levels"].append(level)
		_save_to_file()

static func save_level_as_collectible_collected(world: SceneManager.WORLDS, level: String):
	if not world_data.has(world):
		world_data[world] = {"completed_levels": [], "collectible_levels": []}
	if level not in world_data[world]["collectible_levels"]:
		world_data[world]["collectible_levels"].append(level)
		_save_to_file()

static func is_level_completed(world: SceneManager.WORLDS, level: String) -> bool:
	return world_data.get(world, {}).get("completed_levels", []).has(level)

static func is_collectible_collected(world: SceneManager.WORLDS, level: String) -> bool:
	return world_data.get(world, {}).get("collectible_levels", []).has(level)

# New functions to retrieve lists of levels
static func get_completed_levels(world: SceneManager.WORLDS) -> Array:
	return world_data.get(world, {}).get("completed_levels", [])

static func get_collectible_levels(world: SceneManager.WORLDS) -> Array:
	return world_data.get(world, {}).get("collectible_levels", [])

static func initialize():
	_load_from_file()
