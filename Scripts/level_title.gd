extends FloatingUI


func _ready() -> void:
	super._ready()
	modulate.a = 0
	
func show_title():
	translate()
	return create_tween().tween_property(self, "modulate:a", 1, 0.3)
	
func hide_title():
	return create_tween().tween_property(self, "modulate:a", 0, 0.3)

func translate():
	var level_text = self.text
		
	var regex = RegEx.new()
	regex.compile(r"\d+")
	
	var result = regex.search(level_text)
	if result:
		var level_number = int(result.get_string()) # Convert to int
		self.text = tr("LEVEL %d") % level_number
