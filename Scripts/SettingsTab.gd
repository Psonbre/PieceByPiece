extends VBoxContainer


func _on_visibility_changed() -> void:
	if (visible):
		for child in get_children():
			if child.has_method("_initialize_position"):
				child.call_deferred("_update_position")
			for grandChild in child.get_children():
				if grandChild.has_method("_initialize_position"):
					grandChild.call_deferred("_update_position")
